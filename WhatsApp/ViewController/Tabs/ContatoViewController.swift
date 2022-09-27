//
//  ContatoViewController.swift
//  WhatsApp
//
//  Created by Wesley Camilo on 16/09/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorageUI
class ContatoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var searchBarContatos: UISearchBar!
    @IBOutlet weak var tableViewContatos: UITableView!
    var firestore: Firestore!
    var auth: Auth!
    var idUsuarioLogado: String!
    var listaContatos: [Dictionary<String,Any>] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarContatos.delegate = self
        tableViewContatos.separatorStyle = .none
        auth = Auth.auth()
        firestore = Firestore.firestore()
        // recuperar id do usario
        if let id = auth.currentUser?.uid{
            self.idUsuarioLogado = id
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.recuperarContatos()
    }
    //para configurar a serchBar
    //para pesquisar letra a letra
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            recuperarContatos()
        }
    }
    //para pesquisar apos precionar o botáo
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let textoResultado = searchBar.text {
            if textoResultado != "" {
                pesquisarContatos(texto: textoResultado)
            }
        }
    }
    func pesquisarContatos(texto: String)  {
        let listaFiltro: [Dictionary<String,Any>] = self.listaContatos
        self.listaContatos.removeAll()
        for item in listaFiltro {
            if let nome = item["nome"] as? String {
                if nome.lowercased().contains(texto.lowercased()) {
                    self.listaContatos.append(item)
                }
            }
        }
    }
    func recuperarContatos() {
        //para limpar a lista quando o metodo for chamdo
        self.listaContatos.removeAll()
        firestore.collection("usuarios")
            .document(idUsuarioLogado)
            .collection("contatos")
            .getDocuments { snapshotResultado, erro in
                if let snapshot = snapshotResultado {
                    for document in snapshot.documents{
                        let dadosContatos = document.data()
                        self.listaContatos.append(dadosContatos)
                    }
                    self.tableViewContatos.reloadData()
                }
            }
    }

    /*Metodos para lista na tela*/
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let totalContatos = self.listaContatos.count
        if totalContatos == 0 {
            return 1
        }
        return totalContatos
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaContatos", for: indexPath) as! ContatoTableViewCell
        celula.imageContato.isHidden = false
        if  self.listaContatos.count == 0 {
            celula.textoNome.text = "Nenhum contato cadastrado"
            celula.textoEmail.text = ""
            celula.imageContato.isHidden = true
            return celula
        }
        let indice = indexPath.row
        let dadosContato = self.listaContatos[indice]
        celula.textoNome.text = dadosContato["nome"] as? String
        celula.textoEmail.text = dadosContato["email"] as? String
        if let foto = dadosContato["urlImagem"] as? String {
            celula.imageContato.sd_setImage(with: URL(string: foto), completed: nil)
        }else {
            celula.imageContato.image = UIImage(named: "imagem-perfil")
        }
        return celula
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewContatos.deselectRow(at: indexPath, animated: true)
        let indice = indexPath.row
        let contato = self.listaContatos[indice]
        self.performSegue(withIdentifier: "iniciarConversaContatos", sender: contato)
    }
    //para configurar a view de destino, e passar o contato em que esta sendo enviado a mensagem
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "iniciarConversaContatos" {
            let viewDestino = segue.destination as! MensagensViewController
            viewDestino.contato = sender as? Dictionary
        }
    }
}
