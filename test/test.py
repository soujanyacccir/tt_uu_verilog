import cocotb
from cocotb.triggers import Timer, RisingEdge

@cocotb.test()
async def adder_test(dut):
    dut._log.info("Starting adder test")

    # Make sure outputs settle after reset
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await Timer(10, units="ns")

    # Some test vectors
    tests = [
        (10, 1),
        (20, 30),
        (5, 200),
        (255, 1),   # overflow wraps
        (100, 100),
    ]

    for a, b in tests:
        dut.ui_in.value = a
        dut.uio_in.value = b

        await Timer(10, units="ns")  # allow propagation

        expected = (a + b) & 0xFF
        got = int(dut.uo_out.value)

        dut._log.info(f"ui_in={a}, uio_in={b}, expected={expected}, got={got}")

        assert got == expected, f"Adder FAILED: {a} + {b} = {got}, expected {expected}"

    dut._log.info("Adder test passed!")
