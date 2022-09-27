//
//  ConversasViewController.swift
//  WhatsApp
//
//  Created by Wesley Camilo on 23/09/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorageUI
class ConversasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableViewConversas: UITableView!
    var listaConversa: [Dictionary<String, Any >] = []
    var conversasListener: ListenerRegistration!
    var firestore: Firestore!
    var auth: Auth!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConversas.separatorStyle = .none
        auth = Auth.auth()
        firestore = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        addListenerRecuperarConversas()
    }
    override func viewWillDisappear(_ animated: Bool) {
        conversasListener.remove()
    }
    func addListenerRecuperarConversas()  {
        if let idUsuarioLogado = auth.currentUser?.uid {
           conversasListener = firestore.collection("conversas")
                .document(idUsuarioLogado)
                .collection("ultimas_conversas")
                .addSnapshotListener { querySnapshot, erro in
                    if erro == nil {
                        self.listaConversa.removeAll()
                        if let snapshot = querySnapshot {
                            for document in snapshot.documents {
                                let dados = document.data()
                                self.listaConversa.append(dados)
                            }
                            self.tableViewConversas.reloadData()
                        }
                    }
                }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaConversa.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaConversa", for: indexPath) as! ConversasTableViewCell
        let indice = indexPath.row
        let dados =  self.listaConversa[indice]
        let nome = dados["nomedoUsuario"] as? String
        let ultimaMensagem = dados["ultimaMensagem"] as? String
        celula.nomeConversa.text = nome
        celula.ultimaConversa.text = ultimaMensagem
        if let urlFotoUsuario = dados["urlFotoUsuario"] as? String {
            celula.fotoConversa.sd_setImage(with: URL(string: urlFotoUsuario))
        }else {
            celula.fotoConversa.image = UIImage(named: "imagem-perfil")
            return celula
        }
        return celula
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewConversas.deselectRow(at: indexPath, animated: true)
        let indice = indexPath.row
        let conversa = self.listaConversa[indice]
        if let id = conversa["idDestinatario"] as? String {
            if let nome = conversa["nomedoUsuario"] as? String {
                if let url = conversa["urlFotoUsuario"] as? String {
                    let contato: Dictionary<String, Any> = [
                        "id" : id,
                        "nome" : nome,
                        "urlImagem" : url
                    ]
                    self.performSegue(withIdentifier: "iniciarMensagens", sender: contato)
                }
            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "iniciarMensagens" {
            let viewDestino = segue.destination as! MensagensViewController
            viewDestino.contato = sender as? Dictionary
        }
    }

}
