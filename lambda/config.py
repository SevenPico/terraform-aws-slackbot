import os
import logging
from dataclasses import dataclass

def get_optional_var(name, default=None):
    try:
        return os.environ[name]
    except KeyError:
        logging.warn(f'Environment variable {name} not set. Using default: {default}')
        return default


def get_required_var(name):
    try:
        return os.environ[name]
    except KeyError:
        logging.critical(f'Environment variable {name} not set.')


@dataclass
class Config:
    slack_channels = { c.split('=')[0] : c.split('=')[1] for c in get_required_var('SLACK_CHANNELS').split(',') }
    slack_secret_arn  = get_required_var('SLACK_SECRET_ARN')
