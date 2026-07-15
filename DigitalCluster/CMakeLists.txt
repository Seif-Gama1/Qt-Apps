cmake_minimum_required(VERSION 3.16)

project(DigitalCluster VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appDigitalCluster
    main.cpp
)

qt_add_qml_module(appDigitalCluster
    URI DigitalCluster
    QML_FILES
        Main.qml
        ClusterScreen.qml
        components/CircularGauge.qml
        components/InfoTile.qml
        components/MiniGauge.qml
        components/IconInfoTile.qml
        components/CarOnRoad.qml
        components/Background.qml
        components/WarningIcon.qml
        components/LightIcon.qml
        components/TPMSIcon.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appDigitalCluster PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appDigitalCluster
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appDigitalCluster
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appDigitalCluster
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
