inoreader_resources = gnome.compile_resources(
  'inoreader_res',
  'inoreader.gresource.xml'
)

shared_library(
  'inoreader',
  [
    'InoReaderAPI.vala',
    'InoReaderInterface.vala',
    'InoReaderUtils.vala',
    'InoReaderConnection.vala'
  ],
  inoreader_resources,
  c_args: c_args,
  vala_args: vala_args,
  dependencies: [
    libpeas,
    libgd,
    gtk,
    gee,
    libsecret,
    sqlite3,
    libsoup,
    libxml,
    json_glib,
    webkit2gtk,
    libhandy
  ],
  link_with: [
    communique_lib
  ],
  install: true,
  install_dir: BACKEND_PLUGINS_DIR,
  include_directories: include_directories('../../..')
)

install_data(
  [
    'com.github.suzie97.communique.inoreader.gschema.xml'
  ],
  install_dir: join_paths(SHARE_DIR, 'glib-2.0/schemas')
)

install_data(
  [
    'inoreader.plugin'
  ],
  install_dir: BACKEND_PLUGINS_DIR
)
