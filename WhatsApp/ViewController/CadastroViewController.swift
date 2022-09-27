//
//  CadastroViewController.swift
//  WhatsApp
//
//  Created by Wesley Camilo on 13/09/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class CadastroViewController: UIViewController {
    @IBOutlet weak var campoNome: UITextField!
    @IBOutlet weak var campoEmail: UITextField!
    @IBOutlet weak var campoSenha: UITextField!
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @IBAction func cadastrar(_ sender: Any) {
        let retorno = self.validarCampos()
        if retorno == "" {
            let autenticacao = Auth.auth()
            if let nome = self.campoNome.text{
                if let email = self.campoEmail.text {
                    if let senha = self.campoSenha.text{
                        autenticacao.createUser(withEmail: email, password: senha) { dadosresultados, erro in
                            if erro == nil {
                                // salvar dados do usuario no firebase - cloud firestore
                                if let idUsuario = dadosresultados?.user.uid {
                                    self.firestore.collection("usuarios")
                                        .document(idUsuario)
                                        .setData([
                                            "nome": nome,
                                            "email": email,
                                            "id": idUsuario
                                        ])
                                }
                                
                                print("usuario criado com sucesso")
                            }else {
                                print("Erro ao criar conta do usuário, tente novamente!")
                            }
                        }
                    }
                }
            }
        }else{
            print("O Campo \(retorno) não foi preenchido")
        }
    }
    func validarCampos() -> String {
        if (self.campoNome.text?.isEmpty)! {
            return "Nome"
        }else if(self.campoEmail.text?.isEmpty)!{
            return "E-mail"
        }else if(self.campoSenha.text?.isEmpty)!{
            return "Senha"
        }
        return ""
    }



}
