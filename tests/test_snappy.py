import logging

import pytest

LOGGER = logging.getLogger(__name__)


@pytest.mark.parametrize(
    "name,command",
    [
        (
            "Get operator help",
            "import snappy_esa;from snappy_esa import GPF;from snappy_utils import get_operator_help;get_operator_help('Calibration')",
        ),
        (
            "Get operator default parameters",
            "import snappy_esa;from snappy_esa import GPF;from snappy_utils import get_operator_default_parameters;get_operator_default_parameters('Calibration')",
        ),
    ],
)
def test_snappy(container, name, command):
    """Basic snappy tests"""
    LOGGER.info(f"Testing snappy: {name} ...")
    c = container.run(tty=True, command=["start.sh", "python", "-c", command])
    rv = c.wait(timeout=30)
    assert rv == 0 or rv["StatusCode"] == 0, f"Command {command} failed"
    logs = c.logs(stdout=True).decode("utf-8")
    LOGGER.debug(logs)