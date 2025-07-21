require "test_helper"

class HospitalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clean data for each test
    [ Appointment, Doctor, Patient, HealthcareFacility ].each(&:delete_all)

    # Create test hospitals
    @hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "General Hospital",
      address: "123 Medical Center Drive",
      phone: "+14155551234",
      email: "info@generalhospital.com",
      registration_number: "HOS001",
      active: true,
      status: "active"
    )

    @other_hospital = HealthcareFacility.create!(
      type: "Hospital",
      name: "Children's Hospital",
      address: "456 Kids Care Blvd",
      phone: "+14155555678",
      email: "info@childrenshospital.org",
      registration_number: "HOS002",
      active: true,
      status: "active"
    )

    # Create test doctor associated with hospital
    @doctor = Doctor.create!(
      first_name: "Dr. John",
      last_name: "Smith",
      specialization: "Cardiology",
      hospital: @hospital
    )
  end

  # INDEX action tests
  test "should get index" do
    get hospitals_url
    assert_response :success
    assert_includes @response.body, @hospital.name
    assert_includes @response.body, @other_hospital.name
  end

  test "should get index as JSON" do
    get hospitals_url, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 2, json_response.length
    assert_includes json_response.map { |h| h["name"] }, @hospital.name
  end

  test "should filter hospitals by name" do
    get hospitals_url, params: { search: "General" }
    assert_response :success
    assert_includes @response.body, @hospital.name
    assert_not_includes @response.body, @other_hospital.name
  end

  test "should filter hospitals by location" do
    get hospitals_url, params: { location: "Medical Center" }
    assert_response :success
    assert_includes @response.body, @hospital.name
  end

  # SHOW action tests
  test "should show hospital" do
    get hospital_url(@hospital)
    assert_response :success
    assert_includes @response.body, @hospital.name
    assert_includes @response.body, @hospital.address
  end

  test "should show hospital as JSON" do
    get hospital_url(@hospital), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal @hospital.name, json_response["name"]
    assert_equal @hospital.email, json_response["email"]
  end

  test "should return 404 for non-existent hospital" do
    get hospital_url(id: 99999)
    assert_response :not_found
  end

  # NEW action tests
  test "should get new" do
    get new_hospital_url
    assert_response :success
    assert_includes @response.body, "New Hospital"
  end

  # CREATE action tests
  test "should create hospital" do
    assert_difference("HealthcareFacility.count") do
      post hospitals_url, params: {
        hospital: {
          name: "New Medical Center",
          address: "789 Health Street",
          phone: "+14155559999",
          email: "info@newmedical.com"
        }
      }
    end

    assert_redirected_to hospital_url(HealthcareFacility.last)
    assert_equal "Hospital was successfully created.", flash[:notice]
  end

  test "should create hospital as JSON" do
    assert_difference("HealthcareFacility.count") do
      post hospitals_url, params: {
        hospital: {
          name: "API Medical Center",
          address: "789 API Street",
          phone: "+14155559998",
          email: "api@medical.com"
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(@response.body)
    assert_equal "API Medical Center", json_response["name"]
  end

  test "should not create hospital with invalid data" do
    assert_no_difference("HealthcareFacility.count") do
      post hospitals_url, params: {
        hospital: {
          name: "", # Invalid - blank name
          address: "789 Health Street",
          phone: "+14155559999",
          email: "invalid-email" # Invalid email format
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Name can't be blank"
  end

  test "should not create hospital with invalid data as JSON" do
    assert_no_difference("HealthcareFacility.count") do
      post hospitals_url, params: {
        hospital: {
          name: "",
          address: "",
          phone: "",
          email: ""
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(@response.body)
    assert json_response["errors"].present?
  end

  # EDIT action tests
  test "should get edit" do
    get edit_hospital_url(@hospital)
    assert_response :success
    assert_includes @response.body, @hospital.name
  end

  # UPDATE action tests
  test "should update hospital" do
    patch hospital_url(@hospital), params: {
      hospital: {
        name: "Updated Hospital Name",
        address: @hospital.address,
        phone: @hospital.phone,
        email: @hospital.email
      }
    }

    assert_redirected_to hospital_url(@hospital)
    assert_equal "Hospital was successfully updated.", flash[:notice]
    @hospital.reload
    assert_equal "Updated Hospital Name", @hospital.name
  end

  test "should update hospital as JSON" do
    patch hospital_url(@hospital), params: {
      hospital: {
        name: "JSON Updated Hospital",
        address: @hospital.address,
        phone: @hospital.phone,
        email: @hospital.email
      }
    }, as: :json

    assert_response :ok
    json_response = JSON.parse(@response.body)
    assert_equal "JSON Updated Hospital", json_response["name"]
  end

  test "should not update hospital with invalid data" do
    patch hospital_url(@hospital), params: {
      hospital: {
        name: "", # Invalid
        email: "invalid-email"
      }
    }

    assert_response :unprocessable_entity
    @hospital.reload
    assert_not_equal "", @hospital.name # Should not have changed
  end

  # DESTROY action tests
  test "should destroy hospital" do
    assert_difference("HealthcareFacility.count", -1) do
      delete hospital_url(@hospital)
    end

    assert_redirected_to hospitals_url
    assert_equal "Hospital was successfully deleted.", flash[:notice]
  end

  test "should destroy hospital as JSON" do
    assert_difference("HealthcareFacility.count", -1) do
      delete hospital_url(@hospital), as: :json
    end

    assert_response :no_content
  end

  test "should not destroy hospital with associated doctors" do
    # Hospital has associated doctor, should not be deletable
    assert_no_difference("HealthcareFacility.count") do
      delete hospital_url(@hospital)
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Cannot delete hospital with associated doctors"
  end

  # Custom endpoints tests
  test "should get hospital doctors" do
    get hospital_doctors_url(@hospital)
    assert_response :success
    assert_includes @response.body, @doctor.full_name
  end

  test "should get hospital doctors as JSON" do
    get hospital_doctors_url(@hospital), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 1, json_response.length
    assert_equal @doctor.full_name, json_response.first["full_name"]
  end

  test "should get hospital statistics" do
    get hospital_statistics_url(@hospital)
    assert_response :success
    assert_includes @response.body, "Statistics"
  end

  test "should get hospital statistics as JSON" do
    get hospital_statistics_url(@hospital), as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response.key?("doctor_count")
    assert json_response.key?("specializations")
  end

  test "should search hospitals by specialization" do
    get search_hospitals_url, params: { specialization: "Cardiology" }
    assert_response :success
    assert_includes @response.body, @hospital.name
  end

  test "should get hospitals by emergency services" do
    get hospitals_url, params: { emergency_services: true }
    assert_response :success
  end

  # Error handling tests
  test "should handle invalid hospital ID gracefully" do
    get hospital_url(id: "invalid")
    assert_response :not_found
  end

  test "should handle server errors gracefully" do
    # Simulate server error by stubbing
    HealthcareFacility.stub :find, -> { raise StandardError.new("Test error") } do
      get hospital_url(@hospital)
      assert_response :internal_server_error
    end
  end

  # Pagination tests
  test "should paginate hospitals list" do
    # Create more hospitals to test pagination
    15.times do |i|
      HealthcareFacility.create!(
        type: "Hospital",
        name: "Hospital #{i}",
        address: "#{i} Medical Street",
        phone: "+1415555#{i.to_s.rjust(4, '0')}",
        email: "hospital#{i}@test.com"
      )
    end

    get hospitals_url, params: { page: 2, per_page: 10 }
    assert_response :success
  end

  # Sorting tests
  test "should sort hospitals by name" do
    get hospitals_url, params: { sort: "name", direction: "asc" }
    assert_response :success
  end

  test "should sort hospitals by creation date" do
    get hospitals_url, params: { sort: "created_at", direction: "desc" }
    assert_response :success
  end
end
