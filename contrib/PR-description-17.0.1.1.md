# PR: sccp_manager updates (to chan-sccp/sccp_manager)

**Branch:** `pr-17.0.1.1` → `upstream/develop` (or `master` as per upstream)

## Summary

This PR adds fixes and improvements from timspb/sccp_manager into upstream sccp_manager.

## Main changes

### Install & PHP 8.2+ compatibility
- **Array-to-string safety:** Helper `_sccp_install_scalar_str()` and use everywhere config/DB values are used in string context (`ASTETCDIR`, `AMPWEBROOT`, `AMPDBNAME`/`AMPDBPASS`/`AMPDBUSER`, sccpsettings, installDbPopulateSccpline, createBackUpConfig, Setup_RealTime, checkTftpServer, cleanUpSccpSettings).
- **installDbPopulateSccpline:** Normalize FreePBX devices vs sccpline with scalar keys/values; avoid `array_diff_assoc` array-to-string; use `bindValue` and quoted SQL where needed.
- **createBackUpConfig:** Safe dir/DB vars, mysqldump argument order, path casts, `is_file()` before `unlink`.
- **sccpsettings REPLACE:** All string values passed via `$db->quote()`; numeric fields cast to int.
- **audio_cos/video_cos:** `module.xml` length 11, defaults `0x6`/`0x5`; install widens VARCHAR(1) to VARCHAR(11).
- **PHP:** Require PHP 8.2+ (no 8.3-only code); fix undefined array keys, null parameters, dynamic properties where needed.

### UI, locale, behaviour
- **Status/connection coloring:** Device SCCP Phone and Extensions (Line) tables: row background green/red by connection status (regstate OK); teal header and green borders; phone icon + status text in status cell; case-insensitive MAC match for active devices (ajaxHelper); row classes applied on load-success/post-body with data-index.
- Load Image dropdown in model edit modal from `masterFilesStructure.xml`.
- Remove CP-8821 and forced phone list behaviour; UI/locale and device/form fixes.
- TFTP: writable check, provisioner fallback, modal/i18n; INSTALL guides in `contrib/`, README link.
- README: Deployment section, chan-sccp links, note on patched chan-sccp build if required.

### Other
- Undefined key / null fixes in server.info, ajaxHelper, form.adddevice, Response, helperFunctions, advserver.keyset.
- DB/views: DROP TABLE IF EXISTS before creating views; error messages and schema updates.

## How to update this PR

- Branch `pr-17.0.1.1` is kept in sync with `develop` (merge or fast-forward).
- Push to `origin pr-17.0.1.1` to update the PR on GitHub.
