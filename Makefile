# Code generation
# -----------------------------------------------------------------------------
OPENAPI_SPEC = protocol/service/openapi.yaml
OPENAPI_GEN_SWIFT = .build/debug/swift-openapi-generator
GEN_SWIFT_ROOT = Sources/OFREP/Generated
GEN_SWIFTS = $(GEN_SWIFT_ROOT)/Types.swift,$(GEN_SWIFT_ROOT)/Client.swift

$(OPENAPI_GEN_SWIFT):
	swift build --product swift-openapi-generator

$(GEN_SWIFTS): $(OPENAPI_SPEC) $(OPENAPI_GEN_SWIFT)
	@mkdir -pv $(GEN_SWIFT_ROOT)
	$(OPENAPI_GEN_SWIFT) generate \
		$(OPENAPI_SPEC) \
		--mode types \
		--mode client \
		--naming-strategy idiomatic \
		--access-modifier package \
		--output-directory $(GEN_SWIFT_ROOT)

.PHONY: generate
generate: $(GEN_SWIFTS)
