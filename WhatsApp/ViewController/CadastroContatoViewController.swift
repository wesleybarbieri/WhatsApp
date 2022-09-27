//
//  CadastroContatoViewController.swift
//  WhatsApp
//
//  Created by Wesley Camilo on 20/09/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CadastroContatoViewController: UIViewController {
    @IBOutlet weak var campoEmail: UITextField!    
    @IBOutlet weak var mensagemErro: UILabel!
    var idUsuarioLogado: String!
    var emailUsuarioLOgado: String!
    var auth: Auth!
    var firestore: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        firestore = Firestore.firestore()

        // para verifica se e o mesmo usuario logado
        if let currentUser = auth.currentUser {
            self.idUsuarioLogado = currentUser.uid
            self.emailUsuarioLOgado = currentUser.email
        }
    }
    
    @IBAction func cadastrarContato(_ sender: Any) {
        self.mensagemErro.isHidden = true
        //para verificar se o email digitado nao e o msmdo usuario logado
        if let emailDigitado = campoEmail.text {
            if emailDigitado == self.emailUsuarioLOgado {
                mensagemErro.isHidden = false
                mensagemErro.text = "Você está adicionando seu proprio email!"
                return
            }
            //Verifica se existe o usuario no Firebase
            firestore.collection("usuarios")
                .whereField("email", isEqualTo: emailDigitado)
                .getDocuments { snapshotResultado, erro in
                    //conta total de retorno
                    if let totalItens = snapshotResultado?.count {
                        if totalItens == 0 {
                            self.mensagemErro.text = "Usuario não cadastrado"
                            self.mensagemErro.isHidden = false
                            return
                        }
                    }
                    //salvar contatos
                    if let snapshot = snapshotResultado {
                        for document in snapshot.documents {
                            let dados = document.data()
                            self.salvarContatos(dadosContato: dados)
                        }
                    }
                }
        }
    }
    func salvarContatos(dadosContato: Dictionary<String, Any>) {
        if let idUsuarioCntato = dadosContato["id"] {
            firestore.collection("usuarios")
                .document(idUsuarioLogado)
                .collection("contatos")
                .document(String(describing: idUsuarioCntato))
                .setData(dadosContato) { erro in
                    if erro == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
        }
    }
    


}
