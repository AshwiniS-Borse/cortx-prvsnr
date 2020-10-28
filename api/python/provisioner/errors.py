#
# Copyright (c) 2020 Seagate Technology LLC and/or its Affiliates
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# For any questions about this software or licensing,
# please email opensource@seagate.com or cortx-questions@seagate.com.
#

import subprocess
from typing import Dict, Union, Any


class ProvisionerError(Exception):
    pass


class ProvisionerCliError(ProvisionerError):
    pass


class BadPillarDataError(ProvisionerError):
    pass


class UnknownParamError(ProvisionerError):
    pass


class LogMsgTooLong(ProvisionerError):
    pass


class SubprocessCmdError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(
        self, cmd, cmd_args: Any, reason: Union[str, Exception] = 'unknown'
    ):
        self.cmd = cmd
        self.cmd_args = cmd_args
        if isinstance(reason, subprocess.CalledProcessError):
            self.reason = repr(
                (reason, reason.stdout, reason.stderr)
            )
        else:
            self.reason = repr(reason)

    def __str__(self):
        return (
            "subprocess command failed, reason {}, args {}"
            .format(self.reason, self.cmd_args)
        )


class SaltError(ProvisionerError):
    pass


# TODO TYPING
class SaltCmdError(SaltError):
    _prvsnr_type_ = True

    def __init__(
        self, cmd_args: Any, reason: str = 'unknown'
    ):
        self.cmd_args = cmd_args
        self.reason = reason

    def __str__(self):
        return (
            "salt command failed, reason {}, args {}"
            .format(self.reason, self.cmd_args)
        )


# TODO TEST
class SaltCmdRunError(SaltCmdError):
    pass


class SaltCmdResultError(SaltCmdError):
    pass


# TODO TEST
class SaltNoReturnError(SaltCmdRunError):
    pass


class PrvsnrTypeDecodeError(ProvisionerError, ValueError):
    _prvsnr_type_ = True

    def __init__(self, spec: Dict, reason: Union[str, Exception]):
        self.spec = spec
        self.reason = reason

    def __str__(self):
        return (
            'decode failed for {}, reason: {!r}'
            .format(self.spec, self.reason)
        )


class SWUpdateRepoSourceError(ProvisionerError, ValueError):
    _prvsnr_type_ = True

    def __init__(self, source: str, reason: str):
        self.source = source
        self.reason = reason

    def __str__(self):
        return (
            'repo source {} is not acceptable, reason: {!r}'
            .format(self.source, self.reason)
        )


class PrvsnrCmdError(ProvisionerError):
    def __init__(self, cmd_id: str):
        self.cmd_id = cmd_id


class PrvsnrCmdNotFoundError(ProvisionerError):
    pass


class PrvsnrCmdNotFinishedError(ProvisionerError):
    pass


# TODO IMPROVE DRY
class PillarSetError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, reason: Union[str, Exception], rollback_error=None):
        self.reason = reason
        self.rollback_error = rollback_error

    def __str__(self):
        return (
            'pillar update failed: {!r}'.format(self)
        )

    def __repr__(self):
        return (
            "{}(reason={!r}, rollback_error={!r})"
            .format(self.__class__.__name__, self.reason, self.rollback_error)
        )


class ClusterMaintenanceError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, enable: bool, reason: Union[Exception, str]):
        self.enable = enable
        self.reason = reason

    def __str__(self):
        return (
            'failed to {} cluster maintenance, reason: {!r}'
            .format('enable' if self.enable else 'disable', self.reason)
        )


class ClusterMaintenanceEnableError(ClusterMaintenanceError):
    def __init__(self, reason: Union[Exception, str]):
        super().__init__(True, reason)


class ClusterMaintenanceDisableError(ClusterMaintenanceError):
    def __init__(self, reason: Union[Exception, str]):
        super().__init__(False, reason)


class SWStackUpdateError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, reason: Union[Exception, str]):
        self.reason = reason

    def __str__(self):
        return (
            'failed to update SW stack, reason: {!r}'
            .format(self.reason)
        )


class HAPostUpdateError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, reason: Union[Exception, str]):
        self.reason = reason

    def __str__(self):
        return (
            'failed to apply Hare post_update logic, reason: {!r}'
            .format(self.reason)
        )


class ClusterNotHealthyError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, reason: Union[Exception, str]):
        self.reason = reason

    def __str__(self):
        return (
            'failed to apply Hare post_update logic, reason: {!r}'
            .format(self.reason)
        )


class SWUpdateError(ProvisionerError):
    _prvsnr_type_ = True

    # FIXME reason might be an exception
    def __init__(self, reason: str, rollback_error=None):
        self.reason = reason
        self.rollback_error = rollback_error

    def __str__(self):
        return (
            'update failed: {!r}'.format(self)
        )

    def __repr__(self):
        return (
            "{}(reason={!r}, rollback_error={!r})"
            .format(self.__class__.__name__, self.reason, self.rollback_error)
        )


class SWUpdateFatalError(SWUpdateError):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def __str__(self):
        return "FATAL: {}".format(super().__str__())


class SSLCertsUpdateError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, reason: ProvisionerError, rollback_error=None):
        self.reason = reason
        self.rollback_error = rollback_error

    def __str__(self):
        return (
            'SSL Cert update failed: {!r}'.format(self)
        )

    def __repr__(self):
        return (
            "{}(reason={!r}, rollback_error={!r})"
            .format(self.__class__.__name__, self.reason, self.rollback_error)
        )


class ReleaseFileNotFoundError(ProvisionerError):
    # FIXME reason might be an exception
    def __init__(self, reason: str, rollback_error=None):
        self.reason = reason

    def __str__(self):
        return (
            'RELEASE.INFO or RELEASE_FACTORY.INFO file is not found'
        )

    def __repr__(self):
        return (
            "{}(reason={!r})"
            .format(self.__class__.__name__, self.reason)
        )


class HareClusterError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, funct_name: str, reason: Union[Exception, str]):
        self.funct_name= funct_name
        self.reason = reason

    def __str__(self):
        return (
            'Hare Cluster not in healthy state, reason: {!r}'
            .format(self.reason)
        )


class EnsureUpdateRepoConfigError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, reason: Union[Exception, str]):
        self.reason = reason

    def __str__(self):
        return (
            'Repos are not configured or yum package error, reason: {!r}'
            .format(self.reason)
        )


class UpdateComponentError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, reason: Union[Exception, str]):
        self.reason = reason

    def __str__(self):
        return (
            'Failed to update component, reason: {!r}'
            .format(self.reason)
        )


class SaltMasterError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, funct_name: str, reason: Union[Exception, str]):
        self.funct_name= funct_name
        self.reason = reason

    def __str__(self):
        return (
            'Error occured at Salt Master, reason: {!r}'
            .format(self.reason)
        )


class SaltMinionError(ProvisionerError):
    _prvsnr_type_ = True

    def __init__(self, funct_name: str, reason: Union[Exception, str]):
        self.funct_name= funct_name
        self.reason = reason

    def __str__(self):
        return (
            'Error occurred at Salt Minion, reason: {!r}'
            .format(self.reason)
        )


class SaltMasterConfigurationError(SaltMasterError):
    _prvsnr_type_ = True

    def __init__(self, reason: Union[Exception, str]):
        self.reason = reason

    def __str__(self):
        return (
            'Failed Salt Master configuration, reason: {!r}'
            .format(self.reason)
        )


class SaltMinionConfigurationError(SaltMinionError):
    _prvsnr_type_ = True

    def __init__(self, reason: Union[Exception, str]):
        self.reason = reason

    def __str__(self):
        return (
            'Failed Salt Master configuration, reason: {!r}'
            .format(self.reason)
        )
