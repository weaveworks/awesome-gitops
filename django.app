import imp
import os
import sys
import hashlib
import getpass

def bootstrap_script(path, project_path_components):
    project_path = os.path.join(find_parent_path(path, project_path_components), *project_path_components)
    bootstrap(project_path)

def bootstrap(path):
    path = find_settings_path(path)

    from django.core import management
    try:
        settings = imp.load_source('settings', os.path.join(path, 'settings.py'))
    except ImportError:
        sys.stderr.write("Error: Can't find the file 'settings.py' in the directory containing %r. It appears you've customized things.\nYou'll have to run django-admin.py, passing it your settings module.\n(If the file settings.py does indeed exist, it's causing an ImportError somehow.)\n" % __file__)
        sys.exit(1)

    management.setup_environ(settings)

def find_settings_path(path):
    """Legacy support."""
    return find_parent_path(path, ['settings.py'])

def find_parent_path(path, child_path_components):
    """Retrieve the path of the provided file in the closest parent path from the provided path. (This can be passed into django_utils.bootstrap). You can pass in the __file__ variable, or an absolute path, and it will find the closest file."""
    if os.path.isfile(path):
        path = os.path.dirname(path)

    path = os.path.abspath(path)
    parent_path = os.path.abspath(os.path.join(path, '..'))
    target_path = os.path.join(path, *child_path_components)

    if os.path.exists(target_path):
        return path
    elif path != parent_path:
        return find_parent_path(parent_path, child_path_components)
    else:
        raise Exception('Could not find file path.')

def get_config_identifiers(path):
    config_dir = os.path.join(find_settings_path(path), 'config')
    files = list(os.walk(config_dir))
    if not files:
        sys.stderr.write("Your django application does not appear to have been setup with switchable configurations.\n")
        sys.exit(0)

    files = files[0][2] + files[0][1]
    identifiers = map(lambda name: name.split('.', 1)[0], filter(lambda name: ('.' not in name or name.endswith(".py")) and name not in ('__init__.py', 'base.py',), files))
    return [ (i + 1, x) for i, x in enumerate(identifiers) ]

def setup_environment(path):
    IDENTIFIERS = get_config_identifiers(path)
    CONFIG_IDENTIFIER = os.environ.get('CONFIG_IDENTIFIER', '')

    # If we are trying to use runserver, then look for existing configuration so that auto reload does not keep propmpting for the configuration file.
    if len(sys.argv) >= 2 and sys.argv[1] in ('runserver', 'runserver_plus',):
        if 'CONFIG_IDENTIFIER' in os.environ and CONFIG_IDENTIFIER in [name for id, name in IDENTIFIERS]:
            bootstrap(path)
            return

    IDENTIFIERS_LOOKUP = dict(IDENTIFIERS)
    IDENTIFIERS_REVERSE_LOOKUP = dict([[ name, id ] for id, name in IDENTIFIERS ])

    CONFIG_IDENTIFIER_ID = IDENTIFIERS_REVERSE_LOOKUP.get(CONFIG_IDENTIFIER, '')
    CONFIG_IDENTIFIER_INTERACTIVE = os.environ.get('CONFIG_IDENTIFIER_INTERACTIVE', 'True')

    if CONFIG_IDENTIFIER and CONFIG_IDENTIFIER_INTERACTIVE == 'False':
        print "WARNING: Forced to run environment with %s configuration." % CONFIG_IDENTIFIER.upper()
        return bootstrap(path)

    while True:
        print "Please select your config identifier."
        for id, name in IDENTIFIERS:
            print "   %s) %s" % (id, name)

        try:
            selection = raw_input("What config identifier would you like to use? [%s] " % CONFIG_IDENTIFIER_ID)
        except:
            # Capture if they hard escape during the getpass prompt. Clear the newline, and exit.
            print ''
            sys.exit(0)

        selection = selection.isdigit() and int(selection) or (selection and selection or CONFIG_IDENTIFIER_ID)

        if selection and IDENTIFIERS_LOOKUP.has_key(selection):
            identifier = dict(IDENTIFIERS).get(int(selection))

            # We need to load up the selected settings environment to see if we need to double check for security purposes.
            # If the database_host is not empty (not a local database) then we need to confirm that the user REALLY wants
            # to run the command on a potentially production database.
            settings_path = find_settings_path(path)


            # Set the config identifier to the selected one, so that the correct configuration gets loaded up.
            os.environ['CONFIG_IDENTIFIER'] = identifier
            os.putenv('CONFIG_IDENTIFIER', identifier)

            # Import the settings file into local scope.
            settings = imp.load_source('settings', os.path.join(settings_path, 'settings.py'))

            # Reset the config identifier and system path to what they were before.
            os.putenv('CONFIG_IDENTIFIER', CONFIG_IDENTIFIER)
            os.environ['CONFIG_IDENTIFIER'] = CONFIG_IDENTIFIER

            # If the database host for the selected configuration is not empty (not a local database). Prompt for password.
            if getattr(settings, 'ENABLE_PASSWORD', False) and getattr(settings, 'PASSWORD_DIGEST', ''):
                try:
                    password = getpass.getpass('Please enter the password to load <%s>: ' % identifier)
                except:
                    # Capture if they hard escape during the getpass prompt. Clear the newline, and exit.
                    print ''
                    sys.exit(0)
                else:
                    if hashlib.md5(password).hexdigest() != settings.PASSWORD_DIGEST:
                        print 'Invalid password.'
                        continue


            CONFIG_IDENTIFIER = identifier
            break

    # Update the current config identifier.
    os.environ['CONFIG_IDENTIFIER'] = CONFIG_IDENTIFIER
    os.putenv('CONFIG_IDENTIFIER', CONFIG_IDENTIFIER)

    # Now that we have setup our identifier, initialize our django project.
    bootstrap(path)
