class AddDefaultSpacesToContactInfos < ActiveRecord::Migration[6.0]
  def self.up
    ContactInfo.create(
      name: "Richard L’Abbé Makerspace",
      url: "https://engineering.uottawa.ca/makerspace",
      email: "makerspace@uottawa.ca",
      address: "STM 107, 150 Louis Pasteur",
      phone_number: "613-562-5800 ext. 1559",
      show_hours: true
    )
    OpeningHour.create(
      contact_info_id: ContactInfo.last.id,
      students: "<div>Monday-Friday , 10 am - 6 pm</div>",
      public: "<div>Sunday , 11 am - 5pm</div>",
      summer: "<div>Sunday , 11 am - 5pm</div>"
    )
    ContactInfo.create(
      name: "Brunsfield Center",
      url:
        "https://engineering.uottawa.ca/entrepreneurship/ceed/brunsfield-center",
      email: "brunsfield@uottawa.ca",
      address: "STM 129, 150 Louis Pasteur",
      phone_number: "613-562-5800 ext. 7076",
      show_hours: true
    )
    OpeningHour.create(
      contact_info_id: ContactInfo.last.id,
      students: "<div>Wednesdays &amp; Saturday , 12 pm - 8 pm</div>",
      public: "<div>No public hours</div>",
      summer: "<div>Closed</div>"
    )
    ContactInfo.create(
      name: "Manufacturing Training Centre (MTC)",
      url: "https://engineering.uottawa.ca/ceed/design-spaces/mtc",
      email: "MTC@uottawa.ca",
      address: "STM 137, 150 Louis Pasteur",
      phone_number: "613-562-5800 ext. 7078"
    )
    ContactInfo.create(
      name: "John McEntyre Team Space (JMTS)",
      url: "https://engineering.uottawa.ca/ceed/design-spaces/jmts",
      email: "JMTS@uottawa.ca",
      address: "STEM 128, 150 Louis Pasteur"
    )
    ContactInfo.create(
      name: "MakerLabs",
      url: "https://engineering.uottawa.ca/entrepreneurship/ceed/makerlab",
      email: "makerlab@uottawa.ca",
      address: "STM 119/121, 150 Louis Pasteur"
    )
    ContactInfo.create(
      name: "Sandbox",
      url: "https://engineering.uottawa.ca/entrepreneurship/ceed/sandbox",
      email: "sandbox@uottawa.ca",
      address: "Colonel By building (CBY), 161 Louis Pasteur, Room B109A"
    )
  end
end
