# SCCP Manager

FreePBX module for Cisco SCCP phones.

It manages SCCP extensions, device buttons, BLF, multiple lines, provisioning, and the FreePBX device page integration.

## What you need

- FreePBX 16 or 17
- PHP 8.2+
- Asterisk 21 / 22 / 23
- `chan-sccp` 4.3.5+ from the working fork
- PHP `zip` extension
- TFTP and DHCP for phone provisioning

The stock distro build of `chan-sccp` may be too old or incomplete. Use a patched or working build from the fork linked below.

## Working driver

- Driver: [timspb/chan-sccp](https://github.com/timspb/chan-sccp)
- Driver wiki: [timspb/chan-sccp/wiki](https://github.com/timspb/chan-sccp/wiki)
- Upstream: [chan-sccp/chan-sccp](https://github.com/chan-sccp/chan-sccp)

## Install the module

### From FreePBX web UI

1. Open **Admin** -> **Module Admin**.
2. Click **Upload Modules**.
3. In **Download From Web**, paste:

```text
https://github.com/timspb/sccp_manager/archive/refs/heads/develop.zip
```

4. Click **Download From Web**.
5. Open **Manage Local Modules**.
6. Find **SCCP Manager**.
7. Click **Install**.
8. Click **Process**.
9. Wait for the install to finish.
10. Click **Apply Config** in the top right corner of FreePBX.

### From shell

```bash
cd /var/www/html/admin/modules
git clone https://github.com/timspb/sccp_manager.git
fwconsole ma install sccp_manager
fwconsole reload
```

## Update

```bash
fwconsole ma upgrade sccp_manager
fwconsole reload
```

## Download a ready ZIP

Use this if you want to upload a ready-made package into FreePBX:

```text
https://github.com/timspb/sccp_manager/raw/develop/dist/sccp_manager-17.0.1.1.zip
```

## After install

1. Open **Applications** -> **SCCP Connectivity**.
2. Create or edit phones and lines.
3. Open the extension or phone page and set SCCP values.
4. Click **Apply Config** after saving changes.
5. Restart or reload the phone if needed.

## Troubleshooting

- If FreePBX cannot install the ZIP, check that the URL points to `timspb/sccp_manager`.
- If phones do not provision, verify TFTP and DHCP.
- If registration fails, make sure `chan-sccp` is installed, running, and matches your Asterisk version.
- If SCCP settings do not save, check that the module version is current and that the device page shows the SCCP tab values.

## Notes

- This repository is the working fork used for development.
- The original upstream project is still available at [chan-sccp/chan-sccp](https://github.com/chan-sccp/chan-sccp).
- For this fork, keep using the links above so users do not paste an upstream URL by mistake.
