require 'spec_helper'

RSpec.describe PivotalTrackerPr::CLI do
  let(:cli) { PivotalTrackerPr::CLI.new }
  before do
    ENV['PT_TOKEN'] = 'PT_TOKEN'
    ENV['PT_PROJECT_ID'] = 'PT_PROJECT_ID'
  end

  describe '#create' do
    subject { cli.create story_id }

    context 'param of story_id is nil' do
      let(:story_id) { nil }

      context 'parsed story id is present' do
        before { expect(cli).to receive(:parse_story_id).and_return('111') }

        context 'get_story_name is success' do
          before { expect(PivotalTrackerPr::PivotalTrackerApi).to receive(:get_story_name).with('111').and_return('111 name') }

          it 'should be call write_pull_request_template' do
            expect(cli).to receive(:write_pull_request_template)
            expect(cli).to receive(:system).with('hub pull-request --browse')

            subject
          end
        end

        context 'get_story_name is fail' do
          before { expect(PivotalTrackerPr::PivotalTrackerApi).to receive(:get_story_name).with('111').and_return(nil) }

          it 'should not to be call write_pull_request_template' do
            expect(cli).to_not receive(:write_pull_request_template)
            expect(cli).to receive(:system).with('hub pull-request --browse')

            subject
          end
        end
      end

      context 'parsed story id is nil' do
        before { expect(cli).to receive(:parse_story_id).and_return(nil) }

        it 'should be only call hub command' do
          expect(PivotalTrackerPr::PivotalTrackerApi).to_not receive(:get_story_name)
          expect(cli).to receive(:system).with('hub pull-request --browse')

          subject
        end
      end
    end

    context 'story_id is present'  do
      let(:story_id) { '123' }
      it 'should be call get_story_name && hub command' do
        expect(PivotalTrackerPr::PivotalTrackerApi).to receive(:get_story_name).with('123').and_return('123 name')
        expect(cli).to receive(:write_pull_request_template).with('123', '123 name')
        expect(cli).to receive(:system).with('hub pull-request --browse')

        subject
      end
    end
  end
end
