# Release 17.0.1.1

- Load Image selection was fixed in the edit-model dialog so firmware can be chosen from `masterFilesStructure.xml`.
- README was expanded with a step-by-step "Deployment (what install does)" section covering chan-sccp, backup, database, realtime, driver, TFTP, and the provisioner file.
- `.gitignore` now includes `*.code-workspace`, `.idea/`, and `.phpunit.result.cache`.
- SCCP tab persistence was fixed for Extension Settings, including `vmnum` and `trnsfvm` fields.

---

**Download From Web:**
```
https://github.com/timspb/sccp_manager/archive/refs/tags/v17.0.1.1.zip
```

**Requirements:** FreePBX 16/17, PHP 8.3+, chan-sccp 4.3.5+, TFTP.
