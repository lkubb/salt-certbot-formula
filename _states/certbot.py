"""
Certbot state module
====================

Manage certificates with certbot
"""

# import logging
from salt.exceptions import CommandExecutionError, SaltInvocationError

# log = logging.getLogger(__name__)

__virtualname__ = "certbot"


def __virtual__():
    return __virtualname__


def present(
    name, domains=None, options=None, auth="standalone", install=False, binpath=None
):
    """
    Request a certificate.

    This only manages the creation and included domains.
    Once it has been created, modified options will not result
    in an updated certificate.

    name
        Name of the certificate to retrieve. If domains is unspecified,
        this is be the single domain the certificate will be valid for.

    domains
        List of domains this certificate should be valid for.
        Defaults to empty list, in which case the name will be used as
        the single domain.

    options
        Mapping of options, e.g. {webroot-path: /var/www/example.com}.
        This does not support more advanced configuration options such as
        different webroots for different domains on the same certificate.
        You will need to use the long forms that can be prefixed with
        a double dash.
        If ``webroot`` is specified as auth and you did not include a
        webroot-path, it will default to ``/var/www/<first domain>``.

    auth
        Plugin to use as authenticator. Defaults to ``standalone``.

    install
        Plugin to use as installer. Defaults to False, in which case the
        certificate will only be retrieved, not installed.

    binpath
        Path to the ``certbot`` binary. Can be empty if it's in $PATH.
    """

    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        current = __salt__["certbot.info"](name, binpath) or {"domains": []}
        missing = set(domains or [name]) - set(current["domains"])
        superfluous = set(current["domains"]) - set(domains or [name])
        verb = "create" if not current else "update"

        if current and not missing and not superfluous:
            ret["result"] = True
            ret["comment"] = f"A certificate named '{name}' already exists with the correct domains."
            return ret

        if __opts__["test"]:
            ret["result"] = None
            ret["comment"] = f"Certificate '{name}' would have been {verb}d."
            ret["changes"] = {f"{verb}d": name, "added": list(missing), "removed": list(superfluous)}
        elif __salt__["certbot.get"](name, domains, options, auth, install, binpath):
            ret["comment"] = f"Certificate '{name}' has been {verb}d."
            ret["changes"] = {f"{verb}d": name, "added": list(missing), "removed": list(superfluous)}
        else:
            ret["result"] = False
            ret[
                "comment"
            ] = "Something went wrong calling certbot. This should not happen at all since errors are raised."

    except (CommandExecutionError, SaltInvocationError) as e:
        ret["result"] = False
        ret["comment"] = str(e)
        return ret

    return ret


def absent(name, binpath=None):
    """
    Make sure a certificate is not available.

    name
        Name of the certificate to revoke.

    binpath
        Path to the ``certbot`` binary. Can be empty if it's in $PATH.
    """

    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        if not __salt__["certbot.info"](name, binpath):
            ret["result"] = True
            ret["comment"] = "A certificate named '{}' does not exist.".format(name)
        elif __opts__["test"]:
            ret["result"] = None
            ret["comment"] = "Certificate '{}' would have been deleted.".format(name)
            ret["changes"] = {"deleted": name}
        elif __salt__["certbot.delete"](name, binpath):
            ret["comment"] = "Certificate '{}' has been deleted.".format(name)
            ret["changes"] = {"deleted": name}
        else:
            ret["result"] = False
            ret[
                "comment"
            ] = "Something went wrong calling certbot. This should not happen at all since errors are raised."

    except (CommandExecutionError, SaltInvocationError) as e:
        ret["result"] = False
        ret["comment"] = str(e)
        return ret

    return ret
