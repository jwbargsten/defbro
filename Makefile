.PHONY: all clean test

date=$(shell date +%F)

all:
	# :snippet swift-build
	swift build
	swift run
	# :endsnippet
