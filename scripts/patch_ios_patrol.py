#!/usr/bin/env python3
"""Add RunnerUITests target and drop Flutter SPM refs for Patrol on iOS."""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
PBX = ROOT / "ios/Runner.xcodeproj/project.pbxproj"


def main() -> int:
    text = PBX.read_text()
    if "RunnerUITests" in text and "A1B2C3B62AEBE2B200AD4576" in text:
        print("RunnerUITests already present in project.pbxproj")
        return 0

    # Drop Flutter SPM plugin package (patrol imports XCTest — invalid in app SPM build).
    text = re.sub(
        r"\t\t78A318202AECB46A00862997 /\* FlutterGeneratedPluginSwiftPackage in Frameworks \*/,?\n",
        "",
        text,
    )
    text = re.sub(
        r"\t\t\tpackageProductDependencies = \(\n"
        r"\t\t\t\t78A3181F2AECB46A00862997 /\* FlutterGeneratedPluginSwiftPackage \*/,\n"
        r"\t\t\t\);\n",
        "",
        text,
    )
    text = re.sub(
        r"\t\t\tpackageReferences = \(\n"
        r"\t\t\t\t781AD8BC2B33823900A9FFBB /\* XCLocalSwiftPackageReference \"FlutterGeneratedPluginSwiftPackage\" \*/,\n"
        r"\t\t\t\);\n",
        "",
        text,
    )
    text = re.sub(
        r"\t\t78E0A7A72DC9AD7400C4905E /\* FlutterGeneratedPluginSwiftPackage \*/,?\n",
        "",
        text,
    )
    text = re.sub(
        r"/\* Begin XCLocalSwiftPackageReference section \*/.*?/\* End XCLocalSwiftPackageReference section \*/\n\n",
        "",
        text,
        flags=re.S,
    )
    text = re.sub(
        r"/\* Begin XCSwiftPackageProductDependency section \*/.*?/\* End XCSwiftPackageProductDependency section \*/\n",
        "",
        text,
        flags=re.S,
    )

    insert = """
\t\tA1B2C3BA2AEBE2B200AD4576 /* RunnerUITests.m in Sources */ = {isa = PBXBuildFile; fileRef = A1B2C3B92AEBE2B200AD4576 /* RunnerUITests.m */; };
\t\tC4CD80A2806BBA53CC4676D4 /* Pods_Runner_RunnerUITests.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 77B0713DC63135B5488A774E /* Pods_Runner_RunnerUITests.framework */; };
"""
    text = text.replace("/* End PBXBuildFile section */", insert + "/* End PBXBuildFile section */")

    proxy = """
\t\tA1B2C3BF2AEBE2B200AD4576 /* PBXContainerItemProxy */ = {
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = 97C146E61CF9000F007C117D /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = 97C146ED1CF9000F007C117D;
\t\t\tremoteInfo = Runner;
\t\t};
"""
    text = text.replace("/* End PBXContainerItemProxy section */", proxy + "/* End PBXContainerItemProxy section */")

    files = """
\t\t77B0713DC63135B5488A774E /* Pods_Runner_RunnerUITests.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = Pods_Runner_RunnerUITests.framework; sourceTree = BUILT_PRODUCTS_DIR; };
\t\tA1B2C3B72AEBE2B200AD4576 /* RunnerUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = RunnerUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
\t\tA1B2C3B92AEBE2B200AD4576 /* RunnerUITests.m */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.objc; path = RunnerUITests/RunnerUITests.m; sourceTree = "<group>"; };
"""
    text = text.replace("/* End PBXFileReference section */", files + "/* End PBXFileReference section */")

    frameworks = """
\t\tA1B2C3B42AEBE2B200AD4576 /* Frameworks */ = {
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\tC4CD80A2806BBA53CC4676D4 /* Pods_Runner_RunnerUITests.framework in Frameworks */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
"""
    text = text.replace("/* End PBXFrameworksBuildPhase section */", frameworks + "/* End PBXFrameworksBuildPhase section */")

    text = text.replace(
        "\t\t\tchildren = (\n\t\t\t\t1C08FFAC53E63AB9F5CC4CC9 /* Pods_Runner.framework */,\n\t\t\t\tB74F78A16E5B826F7BB9687F /* Pods_RunnerTests.framework */,\n\t\t\t),",
        "\t\t\tchildren = (\n\t\t\t\t1C08FFAC53E63AB9F5CC4CC9 /* Pods_Runner.framework */,\n\t\t\t\tB74F78A16E5B826F7BB9687F /* Pods_RunnerTests.framework */,\n\t\t\t\t77B0713DC63135B5488A774E /* Pods_Runner_RunnerUITests.framework */,\n\t\t\t),",
    )

    groups = """
\t\tA1B2C3B82AEBE2B200AD4576 /* RunnerUITests */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\tA1B2C3B92AEBE2B200AD4576 /* RunnerUITests.m */,
\t\t\t);
\t\t\tpath = RunnerUITests;
\t\t\tsourceTree = "<group>";
\t\t};
"""
    text = text.replace(
        "\t\t\tchildren = (\n\t\t\t\t9740EEB11CF90186004384FC /* Flutter */,\n\t\t\t\t97C146F01CF9000F007C117D /* Runner */,\n\t\t\t\t97C146EF1CF9000F007C117D /* Products */,\n\t\t\t\t331C8082294A63A400263BE5 /* RunnerTests */,\n\t\t\t\tA5ECACF0F9FE5638B30F1620 /* Pods */,\n\t\t\t\t0DC09A040CD20F09598DC71E /* Frameworks */,\n\t\t\t),",
        "\t\t\tchildren = (\n\t\t\t\t9740EEB11CF90186004384FC /* Flutter */,\n\t\t\t\t97C146F01CF9000F007C117D /* Runner */,\n\t\t\t\t97C146EF1CF9000F007C117D /* Products */,\n\t\t\t\t331C8082294A63A400263BE5 /* RunnerTests */,\n\t\t\t\tA1B2C3B82AEBE2B200AD4576 /* RunnerUITests */,\n\t\t\t\tA5ECACF0F9FE5638B30F1620 /* Pods */,\n\t\t\t\t0DC09A040CD20F09598DC71E /* Frameworks */,\n\t\t\t),",
    )
    text = text.replace(
        "\t\t\tchildren = (\n\t\t\t\t97C146EE1CF9000F007C117D /* Runner.app */,\n\t\t\t\t331C8081294A63A400263BE5 /* RunnerTests.xctest */,\n\t\t\t),",
        "\t\t\tchildren = (\n\t\t\t\t97C146EE1CF9000F007C117D /* Runner.app */,\n\t\t\t\t331C8081294A63A400263BE5 /* RunnerTests.xctest */,\n\t\t\t\tA1B2C3B72AEBE2B200AD4576 /* RunnerUITests.xctest */,\n\t\t\t),",
    )
    text = text.replace("/* End PBXGroup section */", groups + "/* End PBXGroup section */")

    target = """
\t\tA1B2C3B62AEBE2B200AD4576 /* RunnerUITests */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = A1B2C3C52AEBE2B200AD4576 /* Build configuration list for PBXNativeTarget "RunnerUITests" */;
\t\t\tbuildPhases = (
\t\t\t\tA1B2C3C02AEBE2B200AD4576 /* [CP] Check Pods Manifest.lock */,
\t\t\t\tA1B2C3C12AEBE2B200AD4576 /* xcode_backend build */,
\t\t\t\tA1B2C3B32AEBE2B200AD4576 /* Sources */,
\t\t\t\tA1B2C3B42AEBE2B200AD4576 /* Frameworks */,
\t\t\t\tA1B2C3B52AEBE2B200AD4576 /* Resources */,
\t\t\t\tA1B2C3C22AEBE2B200AD4576 /* [CP] Embed Pods Frameworks */,
\t\t\t\tA1B2C3C32AEBE2B200AD4576 /* [CP] Copy Pods Resources */,
\t\t\t\tA1B2C3C42AEBE2B200AD4576 /* xcode_backend embed_and_thin */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\tA1B2C3BE2AEBE2B200AD4576 /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = RunnerUITests;
\t\t\tproductName = RunnerUITests;
\t\t\tproductReference = A1B2C3B72AEBE2B200AD4576 /* RunnerUITests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.ui-testing";
\t\t};
"""
    text = text.replace("/* End PBXNativeTarget section */", target + "/* End PBXNativeTarget section */")

    text = text.replace(
        "\t\t\t\tTargetAttributes = {\n\t\t\t\t\t331C8080294A63A400263BE5 = {\n\t\t\t\t\t\tCreatedOnToolsVersion = 14.0;\n\t\t\t\t\t\tTestTargetID = 97C146ED1CF9000F007C117D;\n\t\t\t\t\t};",
        "\t\t\t\tTargetAttributes = {\n\t\t\t\t\t331C8080294A63A400263BE5 = {\n\t\t\t\t\t\tCreatedOnToolsVersion = 14.0;\n\t\t\t\t\t\tTestTargetID = 97C146ED1CF9000F007C117D;\n\t\t\t\t\t};\n\t\t\t\t\tA1B2C3B62AEBE2B200AD4576 = {\n\t\t\t\t\t\tCreatedOnToolsVersion = 14.2;\n\t\t\t\t\t\tTestTargetID = 97C146ED1CF9000F007C117D;\n\t\t\t\t\t};",
    )
    text = text.replace(
        "\t\t\ttargets = (\n\t\t\t\t97C146ED1CF9000F007C117D /* Runner */,\n\t\t\t\t331C8080294A63A400263BE5 /* RunnerTests */,\n\t\t\t);",
        "\t\t\ttargets = (\n\t\t\t\t97C146ED1CF9000F007C117D /* Runner */,\n\t\t\t\t331C8080294A63A400263BE5 /* RunnerTests */,\n\t\t\t\tA1B2C3B62AEBE2B200AD4576 /* RunnerUITests */,\n\t\t\t);",
    )

    resources = """
\t\tA1B2C3B52AEBE2B200AD4576 /* Resources */ = {
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
"""
    text = text.replace("/* End PBXResourcesBuildPhase section */", resources + "/* End PBXResourcesBuildPhase section */")

    shell = """
\t\tA1B2C3C02AEBE2B200AD4576 /* [CP] Check Pods Manifest.lock */ = {
\t\t\tisa = PBXShellScriptBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\tinputPaths = (
\t\t\t\t"${PODS_PODFILE_DIR_PATH}/Podfile.lock",
\t\t\t\t"${PODS_ROOT}/Manifest.lock",
\t\t\t);
\t\t\tname = "[CP] Check Pods Manifest.lock";
\t\t\toutputPaths = (
\t\t\t\t"$(DERIVED_FILE_DIR)/Pods-Runner-RunnerUITests-checkManifestLockResult.txt",
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t\tshellPath = /bin/sh;
\t\t\tshellScript = "diff \\"${PODS_PODFILE_DIR_PATH}/Podfile.lock\\" \\"${PODS_ROOT}/Manifest.lock\\" > /dev/null\\nif [ $? != 0 ] ; then\\n    echo \\"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\\" >&2\\n    exit 1\\nfi\\necho \\"SUCCESS\\" > \\"${SCRIPT_OUTPUT_FILE_0}\\"\\n";
\t\t\tshowEnvVarsInLog = 0;
\t\t};
\t\tA1B2C3C12AEBE2B200AD4576 /* xcode_backend build */ = {
\t\t\tisa = PBXShellScriptBuildPhase;
\t\t\talwaysOutOfDate = 1;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\tname = "xcode_backend build";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t\tshellPath = /bin/sh;
\t\t\tshellScript = "/bin/sh \\"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\\" build\\n";
\t\t};
\t\tA1B2C3C22AEBE2B200AD4576 /* [CP] Embed Pods Frameworks */ = {
\t\t\tisa = PBXShellScriptBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\tinputFileListPaths = (
\t\t\t\t"${PODS_ROOT}/Target Support Files/Pods-Runner-RunnerUITests/Pods-Runner-RunnerUITests-frameworks-${CONFIGURATION}-input-files.xcfilelist",
\t\t\t);
\t\t\tname = "[CP] Embed Pods Frameworks";
\t\t\toutputFileListPaths = (
\t\t\t\t"${PODS_ROOT}/Target Support Files/Pods-Runner-RunnerUITests/Pods-Runner-RunnerUITests-frameworks-${CONFIGURATION}-output-files.xcfilelist",
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t\tshellPath = /bin/sh;
\t\t\tshellScript = "\\"${PODS_ROOT}/Target Support Files/Pods-Runner-RunnerUITests/Pods-Runner-RunnerUITests-frameworks.sh\\"\\n";
\t\t\tshowEnvVarsInLog = 0;
\t\t};
\t\tA1B2C3C32AEBE2B200AD4576 /* [CP] Copy Pods Resources */ = {
\t\t\tisa = PBXShellScriptBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\tinputFileListPaths = (
\t\t\t\t"${PODS_ROOT}/Target Support Files/Pods-Runner-RunnerUITests/Pods-Runner-RunnerUITests-resources-${CONFIGURATION}-input-files.xcfilelist",
\t\t\t);
\t\t\tname = "[CP] Copy Pods Resources";
\t\t\toutputFileListPaths = (
\t\t\t\t"${PODS_ROOT}/Target Support Files/Pods-Runner-RunnerUITests/Pods-Runner-RunnerUITests-resources-${CONFIGURATION}-output-files.xcfilelist",
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t\tshellPath = /bin/sh;
\t\t\tshellScript = "\\"${PODS_ROOT}/Target Support Files/Pods-Runner-RunnerUITests/Pods-Runner-RunnerUITests-resources.sh\\"\\n";
\t\t\tshowEnvVarsInLog = 0;
\t\t};
\t\tA1B2C3C42AEBE2B200AD4576 /* xcode_backend embed_and_thin */ = {
\t\t\tisa = PBXShellScriptBuildPhase;
\t\t\talwaysOutOfDate = 1;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\tname = "xcode_backend embed_and_thin";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t\tshellPath = /bin/sh;
\t\t\tshellScript = "/bin/sh \\"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\\" embed_and_thin\\n";
\t\t};
"""
    text = text.replace("/* End PBXShellScriptBuildPhase section */", shell + "/* End PBXShellScriptBuildPhase section */")

    sources = """
\t\tA1B2C3B32AEBE2B200AD4576 /* Sources */ = {
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\tA1B2C3BA2AEBE2B200AD4576 /* RunnerUITests.m in Sources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
"""
    text = text.replace("/* End PBXSourcesBuildPhase section */", sources + "/* End PBXSourcesBuildPhase section */")

    dep = """
\t\tA1B2C3BE2AEBE2B200AD4576 /* PBXTargetDependency */ = {
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = 97C146ED1CF9000F007C117D /* Runner */;
\t\t\ttargetProxy = A1B2C3BF2AEBE2B200AD4576 /* PBXContainerItemProxy */;
\t\t};
"""
    text = text.replace("/* End PBXTargetDependency section */", dep + "/* End PBXTargetDependency section */")

    configs = """
\t\tA1B2C3C62AEBE2B200AD4576 /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbaseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
\t\t\tbuildSettings = {
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = PNRU9TBN6A;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.iraq.marketplace.souqiq.RunnerUITests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tTEST_TARGET_NAME = Runner;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\tA1B2C3C72AEBE2B200AD4576 /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbaseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
\t\t\tbuildSettings = {
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = PNRU9TBN6A;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.iraq.marketplace.souqiq.RunnerUITests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tTEST_TARGET_NAME = Runner;
\t\t\t};
\t\t\tname = Release;
\t\t};
\t\tA1B2C3C82AEBE2B200AD4576 /* Profile */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbaseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
\t\t\tbuildSettings = {
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = PNRU9TBN6A;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.iraq.marketplace.souqiq.RunnerUITests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tTEST_TARGET_NAME = Runner;
\t\t\t};
\t\t\tname = Profile;
\t\t};
"""
    text = text.replace("/* End XCBuildConfiguration section */", configs + "/* End XCBuildConfiguration section */")

    conf_list = """
\t\tA1B2C3C52AEBE2B200AD4576 /* Build configuration list for PBXNativeTarget "RunnerUITests" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\tA1B2C3C62AEBE2B200AD4576 /* Debug */,
\t\t\t\tA1B2C3C72AEBE2B200AD4576 /* Release */,
\t\t\t\tA1B2C3C82AEBE2B200AD4576 /* Profile */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t};
"""
    text = text.replace("/* End XCConfigurationList section */", conf_list + "/* End XCConfigurationList section */")

    PBX.write_text(text)
    print(f"Patched {PBX}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
