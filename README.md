# CamSpoof

A rootless jailbreak tweak (Dopamine compatible) that replaces camera output in **all apps** with a photo of your choice.

## How it works

Go to **Settings → CamSpoof**, toggle it on, and pick a photo. Every app's camera will now "take" that photo instead of a real one.

## Building (automatic via GitHub)

1. Push this repo to GitHub
2. GitHub Actions builds the `.deb` automatically
3. Go to **Actions → your latest run → Artifacts** and download `CamSpoof-deb`

To make a proper release: `git tag v1.0.0 && git push origin v1.0.0`
The `.deb` will appear under **Releases**.

## Compatibility

- Rootless jailbreak only (Dopamine, palera1n rootless)
- iOS 14 – 16.x
- arm64 / arm64e

## What gets hooked

| Hook | Covers |
|------|--------|
| `AVCapturePhoto -fileDataRepresentation` | Modern apps (Instagram, Snapchat, etc.) |
| `AVCapturePhoto -CGImageRepresentation` | Apps doing image processing |
| `UIImagePickerController -takePicture` | Older apps using the legacy camera API |
| `AVCaptureStillImageOutput` | Very old apps (pre-iOS 10 style) |
