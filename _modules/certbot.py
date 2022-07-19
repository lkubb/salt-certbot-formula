"""
Certbot execution module
========================

Interact with certbot
"""

from pathlib import Path
import urllib.request

from salt.exceptions import CommandExecutionError, SaltInvocationError
import salt.utils.path
import salt.utils.yaml

__virtualname__ = "certbot"

def __virtual__():
    """
    Does not test for existence of certbot atm. @FIXME
    """
    return __virtualname__


def cli(cmd=None, binpath=None, raise_error=True):
    """
    Run arbitrary Certbot commands. Convenience wrapper for which,
    mostly for internal use.

    CLI Example:

    .. code-block:: bash

        salt '*' certbot.cli [certonly, --standalone, -d, example.com]

    cmd
        Arguments to pass to certbot (list). Each item will be rendered
        separated by a space.

    binpath
        Path to the ``certbot`` binary. Can be empty if it's in $PATH.

    raise_error
        Raise errors when retcode != 0. Defaults to True.
    """

    if cmd is None:
        cmd = []

    if "-n" not in cmd and "--non-interactive" not in cmd:
        cmd.append("--non-interactive")

    if binpath is None:
        binpath = salt.utils.path.which("certbot")

    if not binpath or not Path(binpath).exists():
        raise CommandExecutionError("Could not find certbot executable in '{}'.".format(binpath))

    out = __salt__["cmd.run_all"](" ".join([binpath] + cmd))

    if raise_error and out["retcode"]:
        raise CommandExecutionError("Failed running certbot. Output:\n\n{}\n\n{}".format(out["stderr"], out["stdout"]))

    return out


def list(binpath=None):
    """
    List certificates.

    CLI Example:

    .. code-block:: bash

        salt '*' certbot.list

    binpath
        Path to the ``certbot`` binary. Can be empty if it's in $PATH.
    """
    cmd = ["certificates"]

    out = cli(cmd, binpath)

    certs = []

    if "No certificates found." in out["stdout"]:
        return certs
    elif "Found the following certs:" in out["stdout"]:
        # Ugly, but was as lazy as someone not implementing json output :)
        certsdata = out["stdout"].split("Found the following certs:")[1].strip()

        for cert in certsdata.split("Certificate Name: "):
            if not cert.strip():
                continue
            name, *data = cert.strip().splitlines()
            parsed = {"name": name}
            for line in [x.strip() for x in data]:
                if line.startswith("Domains: "):
                    parsed["domains"] = line[9:].split(" ")
                elif line.startswith("Expiry Date: "):
                    parsed["expires"] = line[13:]
                elif line.startswith("Certificate Path: "):
                    parsed["path_cert"] = line[18:]
                elif line.startswith("Private Key Path: "):
                    parsed["path_priv"] = line[18:]
            certs.append(parsed)
        return certs

    raise CommandExecutionError("Couldn't parse the following output:\n\n{}".format(out["stdout"]))


def exists(name, binpath=None):
    """
    Check if a certificate with this name exists.
    Mind that the name might be different from the domain.

    CLI Example:

    .. code-block:: bash

        salt '*' certbot.exists www.example.com

    name
        Name of the certificate to check.

    binpath
        Path to the ``certbot`` binary. Can be empty if it's in $PATH.
    """
    for cert in list(binpath):
        if cert["name"] == name:
            return True
    return False


def revoke(name=None, path=None, binpath=None):
    """
    Revoke a certificate by name or path.

    CLI Example:

    .. code-block:: bash

        salt '*' certbot.revoke www.example.com

    name
        Name of the certificate to revoke. Defaults to None.

    path
        Path of the certificate to revoke. Defaults to None.

    binpath
        Path to the ``certbot`` binary. Can be empty if it's in $PATH.
    """

    if name is None and path is None:
        raise SaltInvocationError("Need name or path specified to revoke certificate.")

    cmd = ["revoke"]

    if name is not None:
        cmd.extend(["--cert-name", name])
    elif path is not None:
        cmd.extend(["--cert-path", path])

    return cli(cmd, binpath)["stdout"] or True


def delete(name, binpath=None):
    """
    Delete a certificate by name.

    Take care when using this command. Please refer to the
    `official guide <https://eff-certbot.readthedocs.io/en/stable/using.html#safely-deleting-certificates>`_

    CLI Example:

    .. code-block:: bash

        salt '*' certbot.delete www.example.com

    name
        Name of the certificate to revoke.

    binpath
        Path to the ``certbot`` binary. Can be empty if it's in $PATH.
    """

    cmd = ["delete", "--cert-name", name]

    return cli(cmd, binpath)["stdout"] or True


def get(name, domains=None, options=None, auth="standalone", install=False, binpath=None):
    """
    Request a certificate.

    CLI Example:

    .. code-block:: bash

        salt '*' certbot.get www.example.com

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

    if not domains:
        domains = [name]

    if options is None:
        options = {}

    cmd = ["certonly" if not install else "run"]

    cmd.extend(["--" + auth] if not install else ["--authenticator", auth])

    if install:
        cmd.extend(["--installer", install])

    if "webroot" == auth and not options.get("webroot-path"):
        options["webroot-path"] = f"/var/www/{domains[0]}"

    for k, v in options.items():
        cmd.extend(["--" + k, v] if v else ["--" + k])

    cmd.extend(["--cert-name", name])

    for domain in domains:
        cmd.extend(["-d", domain])

    return cli(cmd, binpath)["stdout"] or True
