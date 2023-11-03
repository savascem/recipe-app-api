"""
Test custom django management commands
"""

from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


# check metodun responsunu simule et
@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):

    def test_wait_for_db_ready(self, patched_check):

        # patched_check, patch dekaratorunun taklit ettigi check islemidir.
        patched_check.return_value = True

        # call command cagrilinca bu taklit edilmis islev kullanilir, 
        # argumanida komut ismidir
        call_command('wait_for_db')

        # bir kez kontrol et ve default olan db yi kontrol et
        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):

        patched_check.side_effect = [Psycopg2Error] * 2 + \
        [OperationalError] * 3 + [True]
        
        call_command('wait_for_db')

        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])
