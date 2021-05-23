# code from https://gitlab.com/terradue-ogctb16/eoap/d169-jupyter-nb/eo-processing-snap/-/blob/master/snap-demo.ipynb


def get_operator_help(operator):
    """This function prints the human readable information about a SNAP operator

    Args:
        operator: SNAP operator

    Returns
        The human readable information about the provided SNAP operator.

    Raises:
        None.
    """
    op_spi = GPF.getDefaultInstance().getOperatorSpiRegistry().getOperatorSpi(operator)

    print("Operator name: {}".format(op_spi.getOperatorDescriptor().getName()))
    print("Operator alias: {}\n".format(op_spi.getOperatorDescriptor().getAlias()))
    print("Parameters:\n")
    param_desc = op_spi.getOperatorDescriptor().getParameterDescriptors()

    for param in param_desc:
        print(
            "{}: {}\nDefault Value: {}\n".format(
                param.getName(), param.getDescription(), param.getDefaultValue()
            )
        )
        print("Possible values: {}\n".format(list(param.getValueSet())))


def get_operator_default_parameters(operator):
    """This function returns a Python dictionary with the SNAP operator parameters and their default values, if available.

    Args:
        operator: SNAP operator

    Returns
        A Python dictionary with the SNAP operator parameters and their default values.

    Raises:
        None.
    """
    parameters = dict()

    op_spi = GPF.getDefaultInstance().getOperatorSpiRegistry().getOperatorSpi(operator)
    op_params = op_spi.getOperatorDescriptor().getParameterDescriptors()

    for param in op_params:
        parameters[param.getName()] = param.getDefaultValue()

    return parameters
