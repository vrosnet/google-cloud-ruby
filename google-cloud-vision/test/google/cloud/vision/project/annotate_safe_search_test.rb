# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Vision::Project, :annotate, :safe_search, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }

  it "detects safe_search detection" do
    feature = Google::Apis::VisionV1::Feature.new(type: "SAFE_SEARCH_DETECTION", max_results: 1)
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, safe_search_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, safe_search: true
    mock.verify

    annotation.wont_be :nil?

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?
  end

  it "detects safe_search detection using mark alias" do
    feature = Google::Apis::VisionV1::Feature.new(type: "SAFE_SEARCH_DETECTION", max_results: 1)
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, safe_search_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.mark filepath, safe_search: true
    mock.verify

    annotation.wont_be :nil?

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?
  end

  it "detects safe_search detection using detect alias" do
    feature = Google::Apis::VisionV1::Feature.new(type: "SAFE_SEARCH_DETECTION", max_results: 1)
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, safe_search_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.detect filepath, safe_search: true
    mock.verify

    annotation.wont_be :nil?

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?
  end

  it "detects safe_search detection on multiple images" do
    feature = Google::Apis::VisionV1::Feature.new(type: "SAFE_SEARCH_DETECTION", max_results: 1)
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        ),
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, safe_searches_response_gapi, [req]

    vision.service.mocked_service = mock
    annotations = vision.annotate filepath, filepath, safe_search: true
    mock.verify

    annotations.count.must_equal 2

    annotations.first.safe_search.wont_be :nil?
    annotations.first.safe_search.wont_be :adult?
    annotations.first.safe_search.wont_be :spoof?
    annotations.first.safe_search.must_be :medical?
    annotations.first.safe_search.must_be :violence?

    annotations.last.safe_search.wont_be :nil?
    annotations.last.safe_search.wont_be :adult?
    annotations.last.safe_search.wont_be :spoof?
    annotations.last.safe_search.must_be :medical?
    annotations.last.safe_search.must_be :violence?
  end

  it "uses the default configuration when given a truthy value" do
    feature = Google::Apis::VisionV1::Feature.new(type: "SAFE_SEARCH_DETECTION", max_results: 1)
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, safe_search_response_gapi, [req]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, safe_search: "yep"
    mock.verify

    annotation.wont_be :nil?

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?
  end

  def safe_search_response_gapi
    MockVision::API::BatchAnnotateImagesResponse.new(
      responses: [
        MockVision::API::AnnotateImageResponse.new(
          safe_search_annotation: safe_search_annotation_response
        )
      ]
    )
  end

  def safe_searches_response_gapi
    MockVision::API::BatchAnnotateImagesResponse.new(
      responses: [
        MockVision::API::AnnotateImageResponse.new(
          safe_search_annotation: safe_search_annotation_response
        ),
        MockVision::API::AnnotateImageResponse.new(
          safe_search_annotation: safe_search_annotation_response
        )
      ]
    )
  end
end
