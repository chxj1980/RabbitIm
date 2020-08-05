
# 依赖的第三方库
OPTION(OPTION_RABBITIM_USE_VPX "Use vpx library" ON)
IF(OPTION_RABBITIM_USE_VPX)
    SET(USE_VPX ON)
    IF(PKG_CONFIG_FOUND AND NOT MSVC)
        pkg_check_modules(VPX REQUIRED vpx)
        IF(VPX_FOUND)
            IF(BUILD_SHARED_LIBS)
                add_compile_options(${VPX_CFLAGS})
            ELSE()
                add_compile_options(${VPX_STATIC_CFLAGS})
                SET(VPX_LIBRARIES ${VPX_STATIC_LIBRARIES})
                SET(VPX_LIBRARY_DIRS ${VPX_STATIC_LIBRARY_DIRS})
            ENDIF()
        ENDIF(VPX_FOUND)
    ELSE()
        MESSAGE("Use vpx library:${OPTION_RABBITIM_USE_VPX}")
        FIND_LIBRARY(VPX_LIBRARIES vpx)
    ENDIF()

    IF(ANDROID)
        FIND_LIBRARY(CPU_FEATURES cpu-features)
        if(${CPU_FEATURES} STREQUAL "CPU_FEATURES-NOTFOUND")
            SET(CPU_FEATURES cpu-features)
        endif()
        SET(VPX_LIBRARIES ${VPX_LIBRARIES} ${CPU_FEATURES})
    ENDIF(ANDROID)
    SET(RABBITIM_PACKAGE_REQUIRES ${RABBITIM_PACKAGE_REQUIRES} libvpx-dev)
ELSE(OPTION_RABBITIM_USE_VPX)
    message("Must use libvpx, please install libvpx")
ENDIF(OPTION_RABBITIM_USE_VPX)

OPTION(OPTION_RABBITIM_USE_SPEEX "Use speex library" OFF)
MESSAGE("Use speex library:${OPTION_RABBITIM_USE_SPEEX}")
IF(OPTION_RABBITIM_USE_SPEEX)

    IF(PKG_CONFIG_FOUND AND NOT MSVC)
        pkg_check_modules(SPEEX REQUIRED speex)
        IF(SPEEX_FOUND)
            IF(BUILD_SHARED_LIBS)
                add_compile_options(${SPEEX_CFLAGS})
            ELSE()
                add_compile_options(${SPEEX_STATIC_CFLAGS})
                SET(SPEEX_LIBRARIES ${SPEEX_STATIC_LIBRARIES})
                SET(SPEEX_LIBRARY_DIRS ${SPEEX_STATIC_LIBRARY_DIRS})                
            ENDIF()
        ELSEIF(SPEEX_FOUND)
            FIND_LIBRARY(SPEEX_LIBRARIES NAMES speex speexdsp)
        ENDIF(SPEEX_FOUND)
    ELSE(PKG_CONFIG_FOUND)
        FIND_LIBRARY(SPEEX_LIBRARIES NAMES speex speexdsp)
    ENDIF(PKG_CONFIG_FOUND)

    SET(RABBITIM_PACKAGE_REQUIRES "${RABBITIM_PACKAGE_REQUIRES},libspeex1,libspeexdsp1")
ENDIF(OPTION_RABBITIM_USE_SPEEX)

#libqrencode 库  
IF(PKG_CONFIG_FOUND AND NOT MSVC)
    pkg_check_modules(LIBQRENCODE libqrencode)
    IF(LIBQRENCODE_FOUND)
        IF(BUILD_SHARED_LIBS)
            add_compile_options(${LIBQRENCODE_CFLAGS})
        ELSE()
            add_compile_options(${LIBQRENCODE_STATIC_CFLAGS})
            SET(LIBQRENCODE_LIBRARIES ${LIBQRENCODE_STATIC_LIBRARIES})
            SET(LIBQRENCODE_LIBRARY_DIRS ${LIBQRENCODE_STATIC_LIBRARY_DIRS})
        ENDIF()
        ADD_DEFINITIONS(-DRABBITIM_USE_LIBQRENCODE)
    ENDIF()
ENDIF()

#QZXing库  
IF(PKG_CONFIG_FOUND AND NOT MSVC)
    pkg_check_modules(QZXING QZXing)
    IF(QZXING_FOUND)
        ADD_DEFINITIONS(-DRABBITIM_USE_QZXING)
        IF(BUILD_SHARED_LIBS)
            add_compile_options(${QZXING_CFLAGS})
            INSTALL_TARGETS(TARGETS QZXing)
        ELSE()
            add_compile_options(${QZXING_STATIC_CFLAGS})
            SET(QZXING_LIBRARIES ${QZXING_STATIC_LIBRARIES})
            SET(QZXING_LIBRARY_DIRS ${QZXING_STATIC_LIBRARY_DIRS})
        ENDIF()

    ENDIF()
ELSE()
    FIND_LIBRARY(QZXING_LIBRARIES QZXing2)
ENDIF()

#增加检测ffmpeg库
OPTION(OPTION_RABBITIM_USE_FFMPEG "Use ffmpeg library" ON)
IF(OPTION_RABBITIM_USE_FFMPEG)
    SET(RABBITIM_USE_FFMPEG ON)
    SET(RABBITIM_PACKAGE_REQUIRES "${RABBITIM_PACKAGE_REQUIRES}, libavcodec-dev, libavformat-dev, libavutil-dev")

    ADD_DEFINITIONS("-D__STDC_CONSTANT_MACROS" "-DRABBITIM_USE_FFMPEG") #ffmpeg需要
    
    message("Use pkg-config fail, Manually set ffmpeg library.")
    find_package(FFMPEG REQUIRED avcodec avformat avutil swscale)
    LIST(APPEND RABBITIM_LIBS ${FFMPEG_LIBRARIES})
ENDIF(OPTION_RABBITIM_USE_FFMPEG)
MESSAGE("Use ffmpeg library:${RABBITIM_USE_FFMPEG}")

#增加检测opencv库
OPTION(OPTION_RABBITIM_USE_OPENCV "Use opencv library" OFF)
SET(RABBITIM_USE_OPENCV OFF)
IF(OPTION_RABBITIM_USE_OPENCV)
    find_package(OpenCV COMPONENTS core imgproc video) # videoio)
    IF(OpenCV_FOUND)
        SET(RABBITIM_USE_OPENCV ON)
        INCLUDE_DIRECTORIES("${OpenCV_INCLUDE_DIRS}")
        LINK_DIRECTORIES(${OpenCV_LIB_DIR})
    ENDIF()
ELSEIF(OPTION_RABBITIM_USE_OPENCV)
    IF(ANDROID)
        message("android must opencv library, please install library, and -DOPTION_RABBITIM_USE_OPENCV=ON")
    ENDIF(ANDROID)
ENDIF(OPTION_RABBITIM_USE_OPENCV)
IF(RABBITIM_USE_OPENCV)
    add_definitions("-DRABBITIM_USE_OPENCV")
ENDIF(RABBITIM_USE_OPENCV)
MESSAGE("Use opencv library:${RABBITIM_USE_OPENCV}")

#检测openssl库
OPTION(OPTION_RABBITIM_USE_OPENSSL "Use openssl library" ON)
SET(RABBITIM_USE_OPENSSL OFF)
IF(OPTION_RABBITIM_USE_OPENSSL)
    SET(RABBITIM_USE_OPENSSL ON)
    ADD_DEFINITIONS("-DRABBITIM_USE_OPENSSL")
    SET(RABBITIM_PACKAGE_REQUIRES "${RABBITIM_PACKAGE_REQUIRES}, libssl-dev")

    #IF(PKG_CONFIG_FOUND AND NOT MSVC)
    #    pkg_check_modules(OPENSSL openssl)
    #    IF(OPENSSL_FOUND)
    #        IF(BUILD_SHARED_LIBS)
    #            add_compile_options(${OPENSSL_CFLAGS})    
    #        ELSE()
    #            add_compile_options(${OPENSSL_STATIC_CFLAGS})
    #            SET(OPENSSL_LIBRARIES ${OPENSSL_STATIC_LIBRARIES})
    #            SET(OPENSSL_LIBRARY_DIRS ${OPENSSL_STATIC_LIBRARY_DIRS})
    #        ENDIF()
    #        add_compile_options(${OPENSSL_CFLAGS})
    #    ELSE(OPENSSL_FOUND)
    #        SET(RABBITIM_USE_OPENSSL OFF)
    #    ENDIF(OPENSSL_FOUND)
    #ELSE()
        find_package(OpenSSL)
        IF(OPENSSL_FOUND)
            message("OPENSSL_INCLUDE_DIR:${OPENSSL_INCLUDE_DIR}")
            include_directories(${OPENSSL_INCLUDE_DIR})
            LIST(APPEND RABBITIM_LIBS OpenSSL::SSL OpenSSL::Crypto)
            IF(BUILD_SHARED_LIBS)
                INSTALL(FILES $<TARGET_FILE:OpenSSL::SSL>
                            $<TARGET_FILE:OpenSSL::Crypto>
                            DESTINATION "libs/${ANDROID_ABI}"
                                COMPONENT Runtime)
            endif()
        ELSE(OPENSSL_FOUND)
            SET(RABBITIM_USE_OPENSSL OFF)
        ENDIF(OPENSSL_FOUND)
    #ENDIF()

ENDIF(OPTION_RABBITIM_USE_OPENSSL)
MESSAGE("Use openssl library:${RABBITIM_USE_OPENSSL}")

#检测libcurl库  
OPTION(OPTION_RABBITIM_USE_LIBCURL "Use curl library" OFF)
SET(RABBITIM_USE_LIBCURL OFF)
IF(OPTION_RABBITIM_USE_LIBCURL)
    SET(RABBITIM_USE_LIBCURL ON)
    add_definitions("-DRABBITIM_USE_LIBCURL")
    SET(RABBITIM_PACKAGE_REQUIRES "${RABBITIM_PACKAGE_REQUIRES}, libcurl4-openssl-dev")

    IF(PKG_CONFIG_FOUND AND NOT MSVC)
        pkg_check_modules(CURL libcurl)
        IF(CURL_FOUND)
            IF(BUILD_SHARED_LIBS)
                add_compile_options(${CURL_CFLAGS})
            ELSE()
                add_compile_options(${CURL_STATIC_CFLAGS})
                SET(CURL_LIBRARIES ${CURL_LIBRARIES} ${CURL_STATIC_LIBRARIES})
                SET(CURL_LIBRARY_DIRS ${CURL_STATIC_LIBRARY_DIRS})                
            ENDIF()
        ELSE(CURL_FOUND)
            SET(RABBITIM_USE_LIBCURL OFF)
        ENDIF(CURL_FOUND)
    ELSE()
        find_package(CURL)
        if(CURL_FOUND)
            message("CURL_INCLUDE_DIR:${CURL_INCLUDE_DIR}")
            include_directories(${CURL_INCLUDE_DIR})
            message("CURL_CFLAGS:${CURL_CFLAGS}")
            add_compile_options(-DCURL_STATICLIB)
        ELSE(CURL_FOUND)
            SET(RABBITIM_USE_LIBCURL OFF)
        endif(CURL_FOUND)
    ENDIF()

ENDIF(OPTION_RABBITIM_USE_LIBCURL)
MESSAGE("Use curl library:${RABBITIM_USE_LIBCURL}")

#qxmpp库
OPTION(OPTION_RABBITIM_USE_QXMPP "Use qxmpp library" ON)
if(OPTION_RABBITIM_USE_QXMPP)
    find_package(QXmpp)
    if(QXmpp_FOUND)
        LIST(APPEND RABBITIM_LIBS QXmpp::QXmpp)
        ADD_DEFINITIONS("-DRABBITIM_USE_QXMPP")

        IF(BUILD_SHARED_LIBS)
        INSTALL(FILES $<TARGET_FILE:QXmpp::QXmpp>
                        DESTINATION "libs/${ANDROID_ABI}"
                            COMPONENT Runtime)
        ELSE()
            #连接静态QXMPP库时，必须加上-DQXMPP_STATIC。
            #生成静态QXMPP库时，qmake 需要加上 QXMPP_LIBRARY_TYPE=staticlib 参数
            ADD_DEFINITIONS("-DQXMPP_STATIC")
        ENDIF()
    endif()
ENDIF(OPTION_RABBITIM_USE_QXMPP)
message("Use qxmpp library:${QXmpp_FOUND}")

OPTION(OPTION_RABBITIM_USE_PJSIP "Use pjsip library" OFF)
SET(RABBITIM_USE_PJSIP OFF)
IF(OPTION_RABBITIM_USE_PJSIP)
    SET(RABBITIM_USE_PJSIP ON)
    IF(PKG_CONFIG_FOUND AND NOT MSVC)
        pkg_check_modules(PJSIP REQUIRED libpjproject)
        IF(PJSIP_FOUND)
            add_compile_options(${PJSIP_CFLAGS})
        ENDIF(PJSIP_FOUND)
    ELSE()
        SET(RABBITIM_USE_PJSIP OFF)
    ENDIF()
ENDIF()
message("Use PJSIP library:${RABBITIM_USE_PJSIP}")

message("RABBITIM_LIBS:${RABBITIM_LIBS}")
