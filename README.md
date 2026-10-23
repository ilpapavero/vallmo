# Vallmo

Static website for "Associazione Il Papavero"

Built with [Hugo](https://gohugo.io/) and [Hugobricks](https://github.com/jhvanderschee/hugobricks).

## Gallery photos from Dropbox

The site is rebuilt every day at 04:00 UTC (and on every push). Before the build, the workflow
downloads the shared Dropbox folder and copies every JPG, PNG and WebP photo (subfolders included)
into `static/uploads/gallery`, so they show up in the carousel next to the photos committed in the repository.
Removing a photo from the folder removes it from the site at the next build.
To publish immediately, run the workflow by hand from the Actions tab.

HEIC photos are skipped: upload them as JPG.

One-time setup:

1. In Dropbox, create the folder and share it with the staff who upload photos (*can edit*).
2. Create a link to the folder with *Share → Copy link*, access set to *anyone with the link can view*.
3. In GitHub, *Settings → Secrets and variables → Actions → Secrets*, add `DROPBOX_FOLDER_URL` with that link.

Anyone with the link can see the photos in the folder: keep it only in the GitHub secret.
Without `DROPBOX_FOLDER_URL` the import is skipped and the site builds with the repository photos only.

Test the import script locally with `.github/scripts/test-sync-dropbox-photos.sh`.
