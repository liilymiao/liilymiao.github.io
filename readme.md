# liilymiao.github.io

Source for [liilymiao.github.io](https://liilymiao.github.io), a Jekyll photography blog hosted by GitHub Pages.

## Local preview

The repository uses the GitHub Pages gem set. Install dependencies and start the local server with:

```sh
bundle install --path vendor/bundle
BUNDLE_PATH=vendor/bundle bundle exec jekyll serve
```

Then open <http://127.0.0.1:4000>.

## Content

- Posts live in `_posts/` and use `YYYY-MM-DD-title.md` filenames.
- Albums live in `album/` and use the `album` layout.
- Original photos live in `assets/img/albums/<album>/`.
- Generated thumbnails and lightbox images live in `assets/thumbs/albums/<album>/`.

Keep album URLs in the `/album/<slug>/` form. When changing an existing URL, add `redirect_from` so previously shared links keep working.

## Checks

Run these before publishing:

```sh
python3 tools/check_albums.py
bash check_albums.sh
bash check_color_leaks.sh
BUNDLE_PATH=vendor/bundle bundle exec jekyll build
```

To generate missing image derivatives, install ImageMagick and run:

```sh
bash tools/gen_thumbs.sh
```
