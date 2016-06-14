require 'spec_helper'

RSpec.describe PivotalTrackerPr::CLI do
  before do
    work_path = Dir.mktmpdir
    Dir.chdir work_path

    system 'git init; touch test.rb; git add .; git commit -m init'
    system 'git checkout -b test-111'
  end

  let(:cli) { PivotalTrackerPr::CLI.new }

  describe '#create' do
    subject { cli.create story_id }

    context 'story_id is nil' do
      let(:story_id) { nil }
      it 'should be call say method' do
        expect(cli).to receive(:get_story_name).with('111').and_return('111 name')
        expect(cli).to receive(:write_pull_request_template).with('111', '111 name')
        subject
      end
    end

    context 'story_id is present'  do
      let(:story_id) { 123 }
      it 'should be call say method' do
        expect(cli).to receive(:get_story_name).with('123').and_return('123 name')
        expect(cli).to receive(:write_pull_request_template).with('123', '123 name')
        subject
      end
    end
  end
end
