# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['run.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('macos_claude_overlay/logo/logo_white.png', 'macos_claude_overlay/logo'),
        ('macos_claude_overlay/logo/logo_black.png', 'macos_claude_overlay/logo'),
        ('macos_claude_overlay/about/version.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/author.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/description.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/on_pypi.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/package_name.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/classifiers.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/keywords.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/requirements.txt', 'macos_claude_overlay/about'),
    ],
    hiddenimports=['pyobjc.objc', 'pyobjc', 'Foundation', 'AppKit'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='Claude',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=True,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='macos_claude_overlay/logo/icon.icns',
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='Claude',
)

app = BUNDLE(
    coll,
    name='Claude.app',
    icon='macos_claude_overlay/logo/icon.icns',
    bundle_identifier='com.github.claude',
    info_plist={
        'LSUIElement': True,
        'NSHighResolutionCapable': True,
    },
)
