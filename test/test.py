# test/test.py  — verbose debug version
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

def to_binstr(val, width=8):
    # safe string for LogicArray that may contain X
    s = str(val)                 # recommended instead of .binstr
    s = s.replace("x", "X").replace("z", "Z")
    # pad/truncate to width
    if len(s) < width:
        s = s.zfill(width)
    return s

@cocotb.test()
async def debug_test(dut):
    dut._log.info("Start debug test")

    # start clock (10 us period)
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())

    # init / reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)  # let gl nets settle

    # helper to print status
    async def print_state(tag=""):
        await Timer(1, units="ns")  # small delay for visibility in VCD
        we = (int(dut.uio_in.value) & 1) & int(dut.ena.value)
        dut._log.info(f"{tag} clk={int(dut.clk.value)} rst_n={int(dut.rst_n.value)} ena={int(dut.ena.value)}")
        dut._log.info(f"   ui_in={int(dut.ui_in.value)} bin={to_binstr(dut.ui_in.value,8)}")
        dut._log.info(f"   uio_in={int(dut.uio_in.value)} bin={to_binstr(dut.uio_in.value,8)} we_bit0={int(dut.uio_in.value) & 1} computed_we={we}")
        # gpio_out may be reg => read it
        try:
            gpio_val = int(dut.uo_out.value)
        except Exception:
            gpio_val = None
        dut._log.info(f"   uo_out={dut.uo_out.value} as_int={gpio_val} bin={to_binstr(dut.uo_out.value,8)}")
        # try also to read intermediate signals if present in your RTL (common names)
        for name in ["gpio_out", "seg7", "pwm_out", "pwm_sig"]:
            try:
                sig = getattr(dut, name)
                dut._log.info(f"   {name} = {sig.value} as_int={(int(sig.value) if 'x' not in str(sig.value).lower() else 'X')} bin={to_binstr(sig.value,8)}")
            except Exception:
                # not present
                pass

    # baseline
    await print_state("BASELINE BEFORE WRITES")

    # write single value and monitor cycles around it
    TEST_VALUE = 20
    dut._log.info(f"--- WRITE TEST_VALUE={TEST_VALUE} ---")
    dut.ui_in.value = TEST_VALUE
    dut.uio_in.value = 1
    await print_state("   BEFORE CLOCK EDGE (WE asserted)")
    await ClockCycles(dut.clk, 1)   # write happens on posedge
    await print_state("   JUST AFTER 1st EDGE")
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 3)
    await print_state("   SETTLED AFTER WRITE")

    # Evaluate result
    got_str = to_binstr(dut.uo_out.value,8)
    try:
        got_int = int(dut.uo_out.value)
    except Exception:
        got_int = None

    if got_int != TEST_VALUE:
        dut._log.error(f"WRITE MISMATCH: expected {TEST_VALUE} (bin {TEST_VALUE:08b}), got {got_int} (bin {got_str})")
        # run a bit-pattern investigation: write single-bit values to see mapping
        dut._log.info("--- BIT-MAP CHECK: write single-bit values ---")
        for bit in range(8):
            v = 1 << bit
            dut.ui_in.value = v
            dut.uio_in.value = 1
            await ClockCycles(dut.clk, 1)
            dut.uio_in.value = 0
            await ClockCycles(dut.clk, 3)
            await print_state(f"   AFTER writing single bit {bit} (val={v})")
        # fail the test with clear msg
        assert got_int == TEST_VALUE, f"Expected {TEST_VALUE}, got {got_int}. See logs for bit-map check."
    else:
        dut._log.info(f"WRITE OK: got {got_int}")

    dut._log.info("DEBUG TEST FINISHED")
