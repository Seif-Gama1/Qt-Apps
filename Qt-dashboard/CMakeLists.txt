cmake_minimum_required(VERSION 3.16)

project(Project1 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appProject1
    main.cpp
)

qt_add_qml_module(appProject1
    URI Project1
    QML_FILES
        Main.qml
        RESOURCES res.qrc
        QML_FILES SplashScreen.qml
        QML_FILES Dashboard.qml
        QML_FILES InfoWindow.qml
        QML_FILES GalleryWindow.qml
)

qt_add_resources(appProject1 "resources"
    PREFIX "/"
    FILES
        giphy.gif
        cat_meow_x.wav
        windows-xp-startup.wav
        splash_screen.gif
        splash_scr_audio.wav
        info.png
        gallery.png
        cloudy.png
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appProject1 PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appProject1
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appProject1
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appProject1
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
