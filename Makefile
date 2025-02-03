run:
	@hugo server --buildDrafts --disableFastRender

build:
	@hugo --baseURL="/"

update-theme:
	@git submodule update --remote --merge
