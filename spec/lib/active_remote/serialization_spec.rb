require 'spec_helper'

describe ActiveRemote::Serialization do
  describe "#add_errors_from_response" do
    let(:error) { Generic::Error.new(:field => 'name', :message => 'Boom!') }
    let(:response) {
      tag = Generic::Remote::Tag.new
      tag.errors << error
      tag
    }    

    subject { Tag.new }

    context "when the response has errors" do
      it "adds the errors to the active remote object" do
        subject.add_errors_from_response(response)
        subject.errors[:name].should =~ ['Boom!']
      end
    end

    context "when the response doesn't respond to errors" do
      let(:response) { Generic::Remote::Tag.new }

      it "doesn't add errors" do
        subject.add_errors_from_response(response)
        subject.errors.empty?.should be_true
      end
    end

    context "when no response is given" do
      before { subject.stub(:last_response).and_return(response) }

      it "uses the last response" do
        subject.add_errors_from_response
        subject.errors[:name].should =~ ['Boom!']
      end
    end
  end

  describe "#serialize_records" do
    let(:last_response) {
      MessageWithOptions.new(:records => records)
    }
    let(:records) { [ { :foo => 'bar' } ] }

    subject { Tag.new }

    context "when the last response has records" do

      before { subject.stub(:last_response).and_return(last_response) }

      it "serializes records into active remote objects" do
        subject.serialize_records.each do |record|
          record.should be_a Tag
        end
      end
    end

    context "when the last response doesn't respond to records" do
      it "returns nil" do
        subject.serialize_records.should be_nil
      end
    end
  end
end
