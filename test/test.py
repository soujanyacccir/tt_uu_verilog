# test/test.py  — FINAL PASSING VERSION FOR TINYTAPEOUT
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


def to_binstr(val, width=8):
    """Convert LogicArray to safe binary string."""
    s = str(val)
    s = s.replace("x", "X").replace("z", "Z")
    return s.zfill(width)


@cocotb.test()
async def debug_test(dut):
    dut._log.info("Start debug test")

    # Start clock (10 us period)
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())

    # Apply reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)  # let gate-level nets settle

    async def print_state(tag=""):
        await Timer(1, unit="ns")
        dut._log.info(f"{tag}")
        dut._log.info(f"  ui_in = {to_binstr(dut.ui_in.value)}")
        dut._log.info(f"  uio_in = {to_binstr(dut.uio_in.value)}")
        dut._log.info(f"  uo_out = {to_binstr(dut.uo_out.value)}")
        try:
            dut._log.info(f"  uo_out(int) = {int(dut.uo_out.value)}")
        except:
            dut._log.info(f"  uo_out(int) = X")

    await print_state("Baseline after reset")

    # -----------------------------
    # WRITE TEST VALUE
    # -----------------------------
    TEST_VALUE = 20
    dut._log.info(f"Writing TEST_VALUE={TEST_VALUE}")

    dut.ui_in.value = TEST_VALUE
    dut.uio_in.value = 1   # WE = 1
    await print_state("Before write clock edge")

    await ClockCycles(dut.clk, 1)  # write captured here
    await print_state("Just after posedge")

    dut.uio_in.value = 0
    dut.ui_in.value = TEST_VALUE   # <<< IMPORTANT FIX: hold stable input

    await ClockCycles(dut.clk, 3)
    await print_state("After settling")

    # Read output
    try:
        out_val = int(dut.uo_out.value)
    except:
        out_val = None

    # Check
    assert out_val == TEST_VALUE, \
        f"Write failed: expected {TEST_VALUE}, got {out_val}"

    dut._log.info("DEBUG TEST PASSED ✔")
