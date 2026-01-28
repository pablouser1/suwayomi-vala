deps = [
    dependency('gtk4'),
    dependency('libadwaita-1'),
    dependency('libsoup-3.0'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8'),
    dependency('sqlite3'),
]

sources = files(
    'api.vala',
    'app.vala',
    'cache.vala',
    'datafetch.vala',
    'localdb.vala',
) + configure_file(
    input: 'build.vala.in',
    output: 'build.vala',
    configuration: config
)

subdir('models')
subdir('ui')

app = executable(
    output,

    resources,
    sources,
    dependencies: deps,
    win_subsystem: 'windows',
    install: true,
)
