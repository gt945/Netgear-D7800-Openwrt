
# $(1) : package git directory name, like as "net-cgi.git", should exist on $(GIT_HOME).
# $(2) : git treeish, should be a tag name, commit id, or other valid treeish on $(1) git repository.
define Build/Get/CommonModule
	test x$$(GIT_HOME) != x || (echo "Prepare $$(PKG_NAME) failed: Please specify the GIT_HOME directory"; false)
	test -d $$(GIT_HOME)/$$($(1)) || \
		(echo "Prepare $$(PKG_NAME) failed: Directory $$(GIT_HOME)/$$($(1)) does not exist"; false)
	(cd $$(GIT_HOME)/$$($(1)); git-cat-file -e $$($(2)) || \
		(echo "Prepare $$(PKG_NAME) failed: treeish $$($(2)) does not exist in $$(GIT_HOME)/$$($(1))"; false))
	(cd $$(PKG_BUILD_DIR); git-archive --format=tar --remote=$$(GIT_HOME)/$$($(1)) $$($(2)) | tar -xvf -)
endef

# $(1) : package name, mostly use $(PKG_NAME) when call this definition in Makefile.
define PKG/config/CommonModule
define Package/$(1)/config
	menu "Configuration"
		depends on PACKAGE_$(1)

		config $(1)_GIT_REPO
			string "git repository name of common module for package $(1)"
			default "$(1).git"

		config $(1)_GIT_TREEISH
			string "treeish (tag) in common module used for package $(1)"
			default "HEAD"

		source "$$(SOURCE)/Config.in"
	endmenu
endef
endef
