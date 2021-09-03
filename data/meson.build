UI_RESOURCES = gnome.compile_resources(
  'communique_res',
  'com.github.suzie97.communique.gresource.xml',
)

desktop_file = i18n.merge_file(
  input: 'com.github.suzie97.communique.desktop.in',
  output: 'com.github.suzie97.communique.desktop',
  po_dir: PO_DIR,
  type: 'desktop',
  install: true,
  install_dir: join_paths(SHARE_DIR, 'applications')
)

desktop_autostart_file = i18n.merge_file(
  input: 'com.github.suzie97.communique-autostart.desktop.in',
  output: 'com.github.suzie97.communique-autostart.desktop',
  po_dir: PO_DIR,
  type: 'desktop',
  install: true,
  install_dir: DATA_DIR
)

appdata_file = i18n.merge_file(
  input: 'com.github.suzie97.communique.appdata.xml.in',
  output: 'com.github.suzie97.communique.appdata.xml',
  po_dir: PO_DIR,
  install: true,
  install_dir: join_paths(SHARE_DIR, 'metainfo')
)


desktop_file_validate = find_program('desktop-file-validate', required:false)

if desktop_file_validate.found()
	foreach file: [desktop_file, desktop_autostart_file]
		test (
			'Validate desktop file',
			desktop_file_validate,
			args: file.full_path()
		)
	endforeach
endif

appstreamcli = find_program('appstream-util', required:false)

if appstreamcli.found()
  test (
    'Validate appdata file',
    appstreamcli,
    args: ['validate-relax', '--nonet', appdata_file.full_path()]
  )
endif


subdir('application-icons')

install_subdir('GrabberConfig', install_dir: DATA_DIR)
