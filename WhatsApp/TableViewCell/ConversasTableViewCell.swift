//
//  ConversasTableViewCell.swift
//  WhatsApp
//
//  Created by Wesley Camilo on 23/09/22.
//

import UIKit

class ConversasTableViewCell: UITableViewCell {

    @IBOutlet weak var ultimaConversa: UILabel!
    @IBOutlet weak var nomeConversa: UILabel!
    @IBOutlet weak var fotoConversa: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
