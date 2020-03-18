from pathlib import Path

PRVSNR_ROOT_DIR = Path('/opt/seagate/eos-prvsnr')

# reflects pillar/top.sls
PRVSNR_PILLAR_DIR = PRVSNR_ROOT_DIR / 'pillar'
PRVSNR_USER_PILLAR_DIR = PRVSNR_PILLAR_DIR / 'user'
PRVSNR_USER_PI_ALL_HOSTS_DIR = PRVSNR_USER_PILLAR_DIR / 'groups/all'
PRVSNR_DEF_PI_HOST_DIR_TMPL = str(
    PRVSNR_PILLAR_DIR / 'minions/{minion_id}'
)
PRVSNR_USER_PI_HOST_DIR_TMPL = str(
    PRVSNR_USER_PILLAR_DIR / 'minions/{minion_id}'
)

ALL_MINIONS = '*'

PRVSNR_VALUES_PREFIX = 'PRVSNR_'
PRVSNR_PILLAR_DIR = Path('/opt/seagate/certs')
