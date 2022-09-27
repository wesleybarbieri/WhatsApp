//
//  AjustesViewController.swift
//  WhatsApp
//
//  Created by Wesley Camilo on 14/09/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseStorageUI
class AjustesViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var email: UILabel!
    var imagePicker = UIImagePickerController()
    var firestore: Firestore!  
    var storege: Storage!
    var auth: Auth!
    var idUsuario: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        auth = Auth.auth()
        storege = Storage.storage()
        firestore = Firestore.firestore()
        // recuperar id do usario
        if let id = auth.currentUser?.uid{
            self.idUsuario = id
        }
        // Recuperar dados usuarios
        recuperarDadosUsuario()
    }
    
       @IBAction func sair(_ sender: Any) {
        do {
            try auth.signOut()
        } catch {
            print("Erro ao deslogar o Usuario")
        }
    }
    func recuperarDadosUsuario()  {
        let usuariosRef = self.firestore.collection("usuarios").document(idUsuario)
        usuariosRef.getDocument { snapshot, erro in
            if let dados = snapshot?.data() {
                let nomeUsuario = dados["nome"] as? String
                let emailUsuario = dados["email"] as? String
                
                self.nome.text = nomeUsuario
                self.email.text = emailUsuario
                if let urlImagem = dados["urlImagem"] as? String {
                    self.imagem.sd_setImage(with: URL(string: urlImagem), completed: nil)
                }
            }
        }
    }
    
    @IBAction func escolherImagem(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagemRecuperada = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.imagem.image = imagemRecuperada
        //para fazer o upload da imagem para o storebase
        let imagens = storege.reference().child("imagens")
        if let imagemUpload = imagemRecuperada.jpegData(compressionQuality: 0.3) {
            if let usuarioLogado = auth.currentUser {
                let idUsuario = usuarioLogado.uid
                let nomeImagem = "\(idUsuario).jpg"
                let imagemPerfil = imagens.child("perfil").child(nomeImagem)
                    imagemPerfil.putData(imagemUpload, metadata: nil) { metaData, erro in
                        if erro == nil {
                            //Para atualizar o usuario no firestore add a url da imagem
                            imagemPerfil.downloadURL { url, erro in
                                if let urlimagem = url?.absoluteString{
                                    self.firestore.collection("usuarios").document(idUsuario).updateData([
                                        "urlImagem": urlimagem
                                    ])
                                }
                            }
                            print("Sucesso ao fazer upload da imagem")
                        } else{
                            print("Erro ao fazer upload da imagem")
                        }
                    }
            }
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
