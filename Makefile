.PHONY: help generate build test clean lint all dev genbuild open build-framework build-utilities build-core build-coredatautilities build-di build-networking build-telemetry framework

# Default target
help:
	@echo "Available commands:"
	@echo "  make generate  - Generate Xcode project using XcodeGen"
	@echo "  make build     - Build all frameworks in dependency order"
	@echo "  make genbuild  - Generate, build, and open Xcode project"
	@echo "  make open      - Open Xcode project"
	@echo "  make test      - Run all unit tests"
	@echo "  make clean     - Clean generated files"
	@echo "  make lint      - Run SwiftLint"
	@echo "  make all       - Generate, build, and test"
	@echo "  make dev       - Clean, generate, and build"

	@echo "Flexible framework commands:"
	@echo "  make framework SCHEME=DI"
	@echo "  Available schemes: DI, Registry, CloudStorage, StorageKit, Utilities, CoreDataUtilities, Telemetry, Networking, TruVideoApi, ExternalUtilities, CameraSDK, CoreSDK"

# Generate Xcode project using XcodeGen
generate:
	xcodegen

# Build all frameworks in dependency order
# Foundation Core first (no dependencies), then others that depend on them
build:
	@echo "Building frameworks in dependency order..."
	xcodebuild -project CoreSDK.xcodeproj -scheme DI -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme Registry -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme CloudStorageKit -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme CloudStorageKitTesting -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme StorageKit -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme StorageKitTesting -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme Utilities -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme UtilitiesTesting -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme CoreDataUtilities -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme Telemetry -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme InternalUtilities -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme Networking -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme NetworkingTesting -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme TruVideoApi -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme CameraSDK -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	xcodebuild -project CoreSDK.xcodeproj -scheme CoreSDK -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
	@echo "All frameworks built successfully!"

# Build specific framework by scheme
framework:
	@if [ -z "$(SCHEME)" ]; then \
		echo "Error: Please specify scheme name. Usage: make framework SCHEME=<scheme>"; \
		echo "Available schemes: DI, Registry, Storage, Utilities, CoreDataUtilities, Telemetry, Networking, TruVideoApi, ExternalUtilities, CameraSDK, CoreSDK"; \
		exit 1; \
	fi
	@echo "Building $(SCHEME) framework for device and simulator..."
	@echo "Building for device..."
	xcodebuild -project CoreSDK.xcodeproj -scheme $(SCHEME) -sdk iphoneos -configuration Release -derivedDataPath DerivedData DEFINES_MODULE=YES SWIFT_INSTALL_OBJC_HEADER=NO SWIFT_EMIT_LOC_STRINGS=NO build
	@echo "Building for simulator..."
	xcodebuild -project CoreSDK.xcodeproj -scheme $(SCHEME) -sdk iphonesimulator -configuration Release -derivedDataPath DerivedData DEFINES_MODULE=YES SWIFT_INSTALL_OBJC_HEADER=NO SWIFT_EMIT_LOC_STRINGS=NO build
	@echo "Creating XCFramework for $(SCHEME)..."
	@mkdir -p DerivedData/XCFrameworks
	@if [ -d "DerivedData/Build/Products/Release-iphoneos/$(SCHEME).framework" ] && [ -d "DerivedData/Build/Products/Release-iphonesimulator/$(SCHEME).framework" ]; then \
		xcodebuild -create-xcframework \
			-framework "DerivedData/Build/Products/Release-iphoneos/$(SCHEME).framework" \
			-framework "DerivedData/Build/Products/Release-iphonesimulator/$(SCHEME).framework" \
			-output "DerivedData/XCFrameworks/$(SCHEME).xcframework"; \
		echo "$(SCHEME) XCFramework created successfully!"; \
	else \
		echo "Error: Framework files not found. Check build output above."; \
		exit 1; \
	fi

# Open Xcode project
open:
	@echo "Opening Xcode project..."
	open CoreSDK.xcodeproj

# Generate, build, and open Xcode project
genbuild: generate build open

# Run all tests
test:
	@echo "Running all unit tests..."
	xcodebuild test -project CoreSDK.xcodeproj -scheme DI -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme Registry -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme CloudStorage -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme Storage -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme Utilities -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme CoreDataUtilities -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme Telemetry -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme Networking -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme TruVideoApi -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme CameraSDK -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	xcodebuild test -project CoreSDK.xcodeproj -scheme CoreSDK -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	@echo "All tests completed!"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -rf CoreSDK.xcodeproj
	rm -rf DerivedData
	@echo "Clean completed!"

# Run SwiftLint
lint:
	@echo "Running SwiftLint..."
	swiftlint

# Full workflow: generate, build, and test
all: generate build test

# Development workflow: clean, generate, build
dev: clean generate build 