cmake_minimum_required(VERSION 3.15.3)

project(XMLCoder LANGUAGES Swift)

set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if(CMAKE_SYSTEM_NAME STREQUAL Windows OR CMAKE_SYSTEM_NAME STREQUAL Darwin)
  option(BUILD_SHARED_LIBS "Build shared libraries by default" YES)
endif()

add_library(XMLCoder 
    Sources/XMLCoder/Auxiliaries/Box/BoolBox.swift
    Sources/XMLCoder/Auxiliaries/Box/Box.swift
    Sources/XMLCoder/Auxiliaries/Box/ChoiceBox.swift
    Sources/XMLCoder/Auxiliaries/Box/DataBox.swift
    Sources/XMLCoder/Auxiliaries/Box/DateBox.swift
    Sources/XMLCoder/Auxiliaries/Box/DecimalBox.swift
    Sources/XMLCoder/Auxiliaries/Box/DoubleBox.swift
    Sources/XMLCoder/Auxiliaries/Box/FloatBox.swift
    Sources/XMLCoder/Auxiliaries/Box/IntBox.swift
    Sources/XMLCoder/Auxiliaries/Box/KeyedBox.swift
    Sources/XMLCoder/Auxiliaries/Box/NullBox.swift
    Sources/XMLCoder/Auxiliaries/Box/SharedBox.swift
    Sources/XMLCoder/Auxiliaries/Box/SingleKeyedBox.swift
    Sources/XMLCoder/Auxiliaries/Box/StringBox.swift
    Sources/XMLCoder/Auxiliaries/Box/UIntBox.swift
    Sources/XMLCoder/Auxiliaries/Box/UnkeyedBox.swift
    Sources/XMLCoder/Auxiliaries/Box/URLBox.swift
    Sources/XMLCoder/Auxiliaries/Box/ValueBox.swift
    Sources/XMLCoder/Auxiliaries/ISO8601DateFormatter.swift
    Sources/XMLCoder/Auxiliaries/KeyedStorage.swift
    Sources/XMLCoder/Auxiliaries/Metatypes.swift
    Sources/XMLCoder/Auxiliaries/String+Extensions.swift
    Sources/XMLCoder/Auxiliaries/XMLChoiceCodingKey.swift
    Sources/XMLCoder/Auxiliaries/XMLCoderElement.swift
    Sources/XMLCoder/Auxiliaries/XMLHeader.swift
    Sources/XMLCoder/Auxiliaries/XMLKey.swift
    Sources/XMLCoder/Auxiliaries/XMLStackParser.swift
    Sources/XMLCoder/Decoder/DecodingErrorExtension.swift
    Sources/XMLCoder/Decoder/DynamicNodeDecoding.swift
    Sources/XMLCoder/Decoder/SingleValueDecodingContainer.swift
    Sources/XMLCoder/Decoder/XMLChoiceDecodingContainer.swift
    Sources/XMLCoder/Decoder/XMLDecoder.swift
    Sources/XMLCoder/Decoder/XMLDecoderImplementation.swift
    Sources/XMLCoder/Decoder/XMLDecodingStorage.swift
    Sources/XMLCoder/Decoder/XMLKeyedDecodingContainer.swift
    Sources/XMLCoder/Decoder/XMLUnkeyedDecodingContainer.swift
    Sources/XMLCoder/Encoder/DynamicNodeEncoding.swift
    Sources/XMLCoder/Encoder/EncodingErrorExtension.swift
    Sources/XMLCoder/Encoder/SingleValueEncodingContainer.swift
    Sources/XMLCoder/Encoder/XMLChoiceEncodingContainer.swift
    Sources/XMLCoder/Encoder/XMLEncoder.swift
    Sources/XMLCoder/Encoder/XMLEncoderImplementation.swift
    Sources/XMLCoder/Encoder/XMLEncodingStorage.swift
    Sources/XMLCoder/Encoder/XMLKeyedEncodingContainer.swift
    Sources/XMLCoder/Encoder/XMLReferencingEncoder.swift
    Sources/XMLCoder/Encoder/XMLUnkeyedEncodingContainer.swift)
