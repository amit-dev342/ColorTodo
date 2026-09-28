# Head Room iPhone signing setup

The repository now contains a manual GitHub Actions workflow named **Build Head Room Signed IPA**.

It produces an **Ad Hoc signed IPA** that can be installed directly on registered iPhones.

## Apple Developer setup

In the Apple Developer portal, create or confirm:

1. App ID: `com.amit.headroom`
2. Widget App ID: `com.amit.headroom.widget`
3. App Group: `group.com.amit.headroom`
4. Enable the App Group capability for both App IDs.
5. Register the target iPhone UDID under Devices.
6. Create an **Apple Distribution** certificate.
7. Create an **Ad Hoc provisioning profile** for `com.amit.headroom`.
8. Create an **Ad Hoc provisioning profile** for `com.amit.headroom.widget`.
9. Both Ad Hoc profiles must include the iPhone you want to install Head Room on.

## Files you need

Export the Apple Distribution certificate and its private key from Keychain Access as a password-protected `.p12` file.

Download both `.mobileprovision` files from the Apple Developer portal.

Convert the three files to Base64 before putting them in GitHub Secrets.

macOS:

```bash
base64 -i distribution.p12 | pbcopy
base64 -i HeadRoom.mobileprovision | pbcopy
base64 -i HeadRoomWidget.mobileprovision | pbcopy
```

Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("distribution.p12"))
```

Run the same command for each provisioning profile.

## GitHub Actions secrets

Open:

**Repository -> Settings -> Secrets and variables -> Actions -> New repository secret**

Create these secrets:

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | Your 10-character Apple Developer Team ID |
| `APPLE_DISTRIBUTION_CERTIFICATE_BASE64` | Base64 contents of the exported `.p12` |
| `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD` | Password used when exporting the `.p12` |
| `IOS_APP_PROVISIONING_PROFILE_BASE64` | Base64 contents of the Head Room app Ad Hoc profile |
| `IOS_WIDGET_PROVISIONING_PROFILE_BASE64` | Base64 contents of the Head Room widget Ad Hoc profile |
| `IOS_KEYCHAIN_PASSWORD` | Any strong temporary password used only for the CI keychain |

Do **not** paste certificates, profile contents, passwords, or private keys into source files or commit them to the repository.

## Build the IPA

After all six secrets exist:

1. Open **Actions**.
2. Select **Build Head Room Signed IPA**.
3. Choose **Run workflow** on `main`.
4. Wait for the run to complete successfully.
5. Open the run and download the **HeadRoom-Signed-IPA** artifact.
6. Extract the artifact to get the signed `.ipa`.

Because this is an Ad Hoc build, installation works only on devices whose UDIDs are included in both provisioning profiles.
