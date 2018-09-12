require 'spec_helper'
require_relative '../hash'

describe Hash do
  it "should work with unnormalized characters" do
    xml = '<root>&amp;</root>'
    expect(Hash.from_xml(xml)).to eq({ root: "&" })
  end

  it "should transform a simple tag with content" do
    xml = "<tag>This is the contents</tag>"
    expect(Hash.from_xml(xml)).to eq({ tag: 'This is the contents' })
  end



  it "should transform a simple tag with attributes" do
    xml = "<tag attr1='1' attr2='2'></tag>"
    hash = { :tag => { :@attr1 => '1', :@attr2 => '2' } }
    expect(Hash.from_xml(xml)).to eq(hash)
  end

  it "should transform repeating siblings into an array" do
    xml =<<-XML
          <opt>
            <user login="grep" fullname="Gary R Epstein" />
            <user login="stty" fullname="Simon T Tyson" />
          </opt>
         XML

    expect(Hash.from_xml(xml)[:opt][:user].class).to eq(Array)

    hash = {
        :opt => {
            :user => [{
                           :@login    => 'grep',
                           :@fullname => 'Gary R Epstein'
                       },{
                           :@login    => 'stty',
                           :@fullname => 'Simon T Tyson'
                       }]
        }
    }

    expect(Hash.from_xml(xml)).to eq(hash)
  end

  it "should not transform non-repeating siblings into an array" do
    xml =<<-XML
          <opt>
            <user login="grep" fullname="Gary R Epstein" />
          </opt>
    XML

    expect(Hash.from_xml(xml)[:opt][:user].class).to eq(Hash)

    hash = {
        :opt => {
            :user => {
                :@login => 'grep',
                :@fullname => 'Gary R Epstein'
            }
        }
    }

    expect(Hash.from_xml(xml)).to eq(hash)

  end

  it "should not transform non-repeating siblings into an array" do
    xml =<<-XML
          <opt>
            <user login="grep" fullname="Gary R Epstein" />
          </opt>
    XML

    expect(Hash.from_xml(xml)[:opt][:user].class).to eq(Hash)

    hash = {
        :opt => {
            :user => {
                :@login => 'grep',
                :@fullname => 'Gary R Epstein'
            }
        }
    }

    expect(Hash.from_xml(xml)).to eq(hash)
  end

  it "should prefix attributes with an @-sign to avoid problems with overwritten values" do
    xml =<<-XML
          <multiRef id="id1">
            <login>grep</login>
            <id>76737</id>
          </multiRef>
    XML
    print Hash.from_xml(xml)
    expect(Hash.from_xml(xml)[:multiRef]).to eq({ :login => "grep", :"@id" => "id1", :id => "76737" })
  end

  ["00-00-00", "0000-00-00", "0000-00-00T00:00:00", "0569-23-0141", "DS2001-19-1312654773", "e6:53:01:00:ce:b4:06"].each do |date_string|
    it "should not transform a String like '#{date_string}' to date or time" do
      expect(Hash.from_xml("<value>#{date_string}</value>")[:value]).to eq(date_string)
    end
  end
end