Install_base_packages:
  pkg.installed:
    - pkgs:
      - sudo
      - ipmitool
      - python3
    - reload_modules: True

Install policy packages for SELinux:
  pkg.installed:
    - pkgs:
      - policycoreutils
      - policycoreutils-python

# Install python-pip packages (version 2 and 3)
python-pip:
  pkg.installed:
    - pkgs:
      - python3-pip
    - reload_modules: True
    - bin_env: /usr/bin/pip
    - upgrade: True
