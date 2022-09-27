//
//  MensagensViewController.swift
//  WhatsApp
//
//  Created by Wesley Camilo on 21/09/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class MensagensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var tableViewMensagem: UITableView!
    @IBOutlet weak var fotoBotao: UIButton!
    @IBOutlet weak var mensagemCaixadeTexto: UITextField!
    var listaMensagem: [Dictionary<String, Any>]! = []
    var storege: Storage!
    var firestore: Firestore!
    var auth: Auth!
    var idUsuarioLogado: String!
    var contato: Dictionary<String,Any>!
    var imagePicker = UIImagePickerController()
    var mensagensListener: ListenerRegistration!
    var nomeContato: String!
    var urlFotoContato: String!
    var nomeContatoLogado: String!
    var urlFotoContatoLogado: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        firestore = Firestore.firestore()
        storege = Storage.storage()
        imagePicker.delegate = self
        // recuperar id do usario logado
        if let id = auth.currentUser?.uid{
            self.idUsuarioLogado = id
            recuperarDadosUsuarioLogado()
        }
        //configurar titulo da tela
        if let nome = contato["nome"] as? String {
            nomeContato = nome
            self.navigationItem.title = nomeContato
        }
        if let url = contato["urlImagem"] as? String {
            urlFotoContato = url
            
        }
        //configiracoes da table view
        tableViewMensagem.separatorStyle = .none
        tableViewMensagem.backgroundView = UIImageView(image: UIImage(named: "bg"))
        //configura lista de mensagens
        //listaMensagem = ["ola tudo bem?", "tudo ótimo meu amigo", "Estou muito doente e precisava falar com você meu amigo, será que poderia ir na farmacia e pegar alguns remedios?", "posso sim"]
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        addListenerRecuperarMensagem()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        mensagensListener.remove()
    }
    @IBAction func enviarImagem(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagemRecuperada = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imagens = storege.reference().child("imagens")
        if let imagemUpload = imagemRecuperada.jpegData(compressionQuality: 0.3) {
            let identificadorUnico = UUID().uuidString
            let nomeImagem = "\(identificadorUnico).jpg"
            let imagemMensagemRef = imagens.child("mensagens").child(nomeImagem)
            imagemMensagemRef.putData(imagemUpload, metadata: nil) { metaData, erro in
                if erro == nil {
                    print("Sucesso ao fazer upload da imagem")
                    imagemMensagemRef.downloadURL { [self] url, erro in
                        if let urlImagem = url?.absoluteString{
                            if let idUsuariosDestinatario = contato["id"] as? String {
                                let mensagem: Dictionary<String, Any> = [
                                    "idUsuario": idUsuarioLogado!,
                                    "urlImagem": urlImagem,
                                    "data" : FieldValue.serverTimestamp()
                                ]
                                //salvando mensagens para remetente
                                salvarMensagem(idRemetente: idUsuarioLogado, idDestinatario: idUsuariosDestinatario, mensagem: mensagem)
                                //salvando mensagens para o destinatario
                                salvarMensagem(idRemetente: idUsuariosDestinatario, idDestinatario: idUsuarioLogado, mensagem: mensagem)
                                var conversa: Dictionary<String, Any> = [
                                    "ultimaMensagem": "imagem..."
                                ]
                                //salvar conversa para o remetente(dados de quem recebe)
                                conversa["idRemetente"] = idUsuarioLogado!
                                conversa["idDestinatario"] = idUsuariosDestinatario
                                conversa["nomedoUsuario"] = self.nomeContato!
                                conversa["urlFotoUsuario"] = self.urlFotoContato!
                                
                                salvarConversa(idRemetente: idUsuarioLogado, idDestinatario: idUsuariosDestinatario, conversa: conversa)
                                // salvar conversa para o destinatario(dados de quem enviqa)
                                conversa["idRemetente"] = idUsuariosDestinatario
                                conversa["idDestinatario"] = idUsuarioLogado!
                                conversa["nomedoUsuario"] = self.nomeContatoLogado
                                conversa["urlFotoUsuario"] = self.urlFotoContatoLogado
                                salvarConversa(idRemetente: idUsuariosDestinatario, idDestinatario: idUsuarioLogado, conversa: conversa)
                            
                               
                            }
                        }
                    }
                } else {
                    print("Erro ao fazer upload da imagem")
                }
            }
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func enviarMensagens(_ sender: Any) {
        if let textoDigitado = mensagemCaixadeTexto.text {
            if !textoDigitado.isEmpty {
                if let idUsuariosDestinatario = contato["id"] as? String {
                    let mensagem: Dictionary<String, Any> = [
                        "idUsuario": idUsuarioLogado!,
                        "texto": textoDigitado,
                        "data" : FieldValue.serverTimestamp()
                    ]
                    //salvando mensagens para remetente
                    salvarMensagem(idRemetente: idUsuarioLogado, idDestinatario: idUsuariosDestinatario, mensagem: mensagem)
                    //salvando mensagens para o destinatario
                    salvarMensagem(idRemetente: idUsuariosDestinatario, idDestinatario: idUsuarioLogado, mensagem: mensagem)
                    var conversa: Dictionary<String, Any> = [
                        "ultimaMensagem": textoDigitado
                    ]
                    //salvar conversa para o remetente(dados de quem recebe)
                    conversa["idRemetente"] = idUsuarioLogado!
                    conversa["idDestinatario"] = idUsuariosDestinatario
                    conversa["nomedoUsuario"] = self.nomeContato!
                    conversa["urlFotoUsuario"] = self.urlFotoContato!
                    
                    salvarConversa(idRemetente: idUsuarioLogado, idDestinatario: idUsuariosDestinatario, conversa: conversa)
                    // salvar conversa para o destinatario(dados de quem enviqa)
                    conversa["idRemetente"] = idUsuariosDestinatario
                    conversa["idDestinatario"] = idUsuarioLogado!
                    conversa["nomedoUsuario"] = self.nomeContatoLogado
                    conversa["urlFotoUsuario"] = self.urlFotoContatoLogado
                    salvarConversa(idRemetente: idUsuariosDestinatario, idDestinatario: idUsuarioLogado, conversa: conversa)
                }
            }
        }
    }
    func recuperarDadosUsuarioLogado()  {
        let usuariosRef = self.firestore.collection("usuarios").document(idUsuarioLogado)
        usuariosRef.getDocument { documentSnapshot, erro in
            if erro == nil {
                if let dados = documentSnapshot?.data(){
                    if let url = dados["urlImagem"] as? String {
                        if let nome = dados["nome"] as? String {
                            self.urlFotoContatoLogado = url
                            self.nomeContatoLogado = nome
                        }
                    }
                }
                
            }
        }
        
    }
    func salvarConversa(idRemetente: String, idDestinatario: String, conversa: Dictionary<String, Any>)   {
        firestore.collection("conversas")
            .document(idRemetente)
            .collection("ultimas_conversas")
            .document(idDestinatario)
            .setData(conversa)
    }
    func salvarMensagem(idRemetente: String, idDestinatario: String, mensagem: Dictionary<String, Any>)  {
        firestore.collection("mensagens")
            .document(idRemetente)
            .collection(idDestinatario)
            .addDocument(data: mensagem)
        //limpar caixa de texto
        mensagemCaixadeTexto.text = ""
        
    }
    // para listar as mensagens recuperando as
    func addListenerRecuperarMensagem()  {
        if let idDestinatario = contato["id"] as? String {
            mensagensListener = firestore.collection("mensagens")
                .document(idUsuarioLogado)
                .collection(idDestinatario)
                .order(by: "data", descending: false)
                .addSnapshotListener { querySnapshot, erro in
                    // Para limpa a lista quando, para depois add apenas a ultima mensagem enviada
                    self.listaMensagem.removeAll()
                    //Recuperar dados
                    if let snapshot = querySnapshot {
                        for document in snapshot.documents {
                            let dados = document.data()
                            self.listaMensagem.append(dados)
                        }
                        self.tableViewMensagem.reloadData()
                    }
                }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaMensagem.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celulaDireita = tableView.dequeueReusableCell(withIdentifier: "celulaMensagensDIreita", for: indexPath) as! MensagensTableViewCell
        let celulaEsquerda = tableView.dequeueReusableCell(withIdentifier: "celulaMensagensEsquerda", for: indexPath) as! MensagensTableViewCell
        let celulaImagemDireita = tableView.dequeueReusableCell(withIdentifier: "celulaImagemDireita", for: indexPath) as! MensagensTableViewCell
        let celulaImagemEsquerda = tableView.dequeueReusableCell(withIdentifier: "celulaImagemEsquerda", for: indexPath) as! MensagensTableViewCell
        //para semparar as mensagens usando a auternancia "indice % 2 == 0"
        let indice = indexPath.row
        let dados = self.listaMensagem[indice]
        let texto = dados["texto"] as? String
        let idUsuario = dados["idUsuario"] as? String
        let urlImagem = dados["urlImagem"] as? String
        if idUsuarioLogado == idUsuario {
            if urlImagem != nil {
                celulaImagemDireita.imagemDireita.sd_setImage(with: URL(string: urlImagem!))
                return celulaImagemDireita
            }
            celulaDireita.mensagemDireitaLabel.text = texto
            return celulaDireita
        } else {
            if urlImagem != nil {
                celulaImagemEsquerda.imagemEsquerda.sd_setImage(with: URL(string: urlImagem!))
                return celulaImagemEsquerda
            }
            celulaEsquerda.mensagemEsquerdaLabel.text = texto
           return celulaEsquerda
        }
    }

}
