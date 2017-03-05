use Mix.Config

config :mnesia, dir: '/home/sam/Documents/mnesia/geosnap'

config :store_house, [
  disc_nodes: [:"mnesia@tactical-thinkpad"],
  table_definitions: [
    api_key: [
      disc_copies: [],
      ram_copies: []
    ],
    application: [
      disc_copies: [],
      ram_copies: []
    ],
    category: [
      disc_copies: [],
      ram_copies: []
    ],
    comment: [
      disc_copies: [],
      ram_copies: []
    ],
    picture_vote: [
      disc_copies: [],
      ram_copies: [],
      record_name: :vote
    ],
    picture: [
      disc_copies: [],
      ram_copies: []
    ],
    score: [
      disc_copies: [],
      ram_copies: []
    ],
    user: [
      disc_copies: [],
      ram_copies: []
    ],
  ]
]
