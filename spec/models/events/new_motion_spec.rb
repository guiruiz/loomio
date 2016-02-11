require 'rails_helper'

describe Events::NewMotion do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:motion) { create :motion, discussion: discussion }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewMotion.publish!(motion) }.to change { Event.where(kind: 'new_motion').count }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewMotion.publish!(motion)).to be_a Event
    end
  end

  describe 'channel_object' do
    it 'uses its group as the channel to publish to' do
      expect(Events::NewMotion.publish!(motion).send(:channel_object)).to eq discussion.group
    end
  end
end
