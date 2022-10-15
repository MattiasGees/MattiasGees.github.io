.PHONY: help
help:

serve:
	docker run --volume=$PWD:/srv/jekyll --publish 4000:4000 --name jekyll jekyll/jekyll jekyll serve

stop:
	docker stop jekyll
	docker rm jekyll
