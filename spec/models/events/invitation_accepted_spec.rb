require 'rails_helper'

describe Events::InvitationAccepted do
  let(:membership){ create(:membership) }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::InvitationAccepted.publish!(membership) }.to change { Event.where(kind: 'invitation_accepted').count }.by(1)
    end

    it 'returns an event' do
      expect(Events::InvitationAccepted.publish!(membership)).to be_a Event
    end
  end
end
