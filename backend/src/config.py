from configparser import ConfigParser


def load_database_config(filename="..\configurations.ini", section="postgresql"):
    parser = ConfigParser()
    parser.read(filename)
    if parser.has_section(section):
        db = {param[0]: param[1] for param in parser.items(section)}
    else:
        raise Exception('Section {0} is not found in the {1} file.'.format(section, filename))

    return db
