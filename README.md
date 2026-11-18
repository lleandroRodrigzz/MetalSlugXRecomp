# Metal Slug X Recompiled

Port nativo para Windows do **Metal Slug X (PlayStation, USA — SLUS-01212)**, feito por
**recompilação estática** com o [psxrecomp](https://github.com/mstan/psxrecomp). O executável
do PS1 é traduzido para C e compilado como um programa nativo do PC, sem emular a CPU.

<p align="center">
  <img src="docs/screenshots/launcher.png" alt="Launcher com o disco verificado e o controle do Player 1 conectado" width="720">
</p>

| Seleção de personagem | Início da Missão 1 |
|---|---|
| ![Soldier Select](docs/screenshots/soldier-select.png) | ![Missão 1](docs/screenshots/missao-1-inicio.png) |
| **Gameplay** | **Heavy Machine Gun** |
| ![Gameplay](docs/screenshots/gameplay-1.png) | ![Heavy Machine Gun](docs/screenshots/gameplay-heavy-machine-gun.png) |

## Recursos

- Executável nativo para Windows (64 bits)
- Launcher com verificação do disco, configuração de controles e memory cards virtuais
- **2 jogadores locais** (controles Xbox, DualShock e DualSense)
- Opções de vídeo do psxrecomp (resolução interna maior, widescreen)

---

## Como instalar (passo a passo)

São **5 passos**. Você só faz isso uma vez.

### Passo 1 — Tenha a imagem do SEU disco

Este repositório **não contém o jogo**. Você precisa da imagem do seu próprio disco de
**Metal Slug X (USA)** no formato **BIN/CUE**: são dois arquivos, um `.bin` e um `.cue`, que
devem ficar juntos na mesma pasta.

- Você pode encontrar o jogo no site ROMSFUN.COM (Recomendado), procure o "Metal Slug X" na categoria de Roms "Playstation"
- A imagem precisa ser exatamente esta (o jogo confere na hora de abrir):

  | Campo | Valor esperado |
  |---|---|
  | Serial | SLUS-01212 |
  | Tamanho do `.bin` | 104.315.904 bytes |
  | SHA1 do `.bin` | `f1ea9a0ae2115f476bd4767b1ac0ba9d0b5ac972` |

- Se sua imagem estiver em **CHD**, converta para BIN/CUE com o `chdman` (vem com o MAME):

  ```bash
  chdman extractcd -i "Metal Slug X.chd" -o "Metal Slug X (USA).cue" -ob "Metal Slug X (USA).bin"
  ```

> Guarde a imagem numa pasta fixa, por exemplo `C:\Jogos\Metal Slug X (USA)\`.
> O jogo lê o disco dessa pasta toda vez que abre, então não mova nem apague a imagem depois.

### Passo 2 — Instale o Git e o Python

1. Clique com o botão direito no **menu Iniciar** e escolha **Terminal** (ou **Windows PowerShell**).
2. Cole este comando e aperte **Enter**:

   ```powershell
   winget install Git.Git Python.Python.3.12
   ```

3. Aceite o que for pedido e espere terminar.
4. **Feche a janela do PowerShell e abra uma nova.** Sem isso, os comandos novos não são reconhecidos.

> Já tem Git e Python instalados? Pode pular este passo.

### Passo 3 — Baixe este projeto

No PowerShell novo, cole os dois comandos abaixo, um de cada vez, apertando **Enter** depois de cada um:

```powershell
cd $HOME\Downloads
```

```powershell
git clone https://github.com/lleandroRodrigzz/MetalSlugXRecomp.git
```

Isso cria a pasta `Downloads\MetalSlugXRecomp`.

### Passo 4 — Rode o instalador

Ainda no PowerShell, cole:

```powershell
cd MetalSlugXRecomp
```

```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

1. Vai abrir uma janela pedindo o arquivo **`.cue`** do Metal Slug X. Selecione-o e clique em **Abrir**.
2. O instalador faz tudo sozinho:
   - baixa o psxrecomp, o launcher e um compilador (cerca de 209 MB);
   - gera o código do jogo a partir do seu disco;
   - compila o jogo;
   - cria o atalho **Metal Slug X Recompiled** na Área de Trabalho.
3. **Espere de 20 a 40 minutos** e não feche a janela. Vão aparecer muitas mensagens, e isso é normal.
4. Quando aparecer **"Pronto!"** em verde, terminou.

### Passo 5 — Jogue

1. Abra o atalho **Metal Slug X Recompiled** na Área de Trabalho.
2. No launcher, confira se aparece **✓ Disc verified**. Se não aparecer, clique em
   **Browse For Disc / SBI** e escolha o seu `.cue`.
3. Clique em **PLAY**.

> Não mova o `MetalSlugX_Recompiled.exe` para fora da pasta `build-release`, porque ele usa os
> arquivos que estão ao lado. Se quiser outro atalho, clique com o botão direito no `.exe` →
> **Enviar para** → **Área de trabalho (criar atalho)**.

---

## Dois jogadores

1. Conecte os **dois controles** antes de abrir o jogo.
2. No launcher, configure um controle na aba **PLAYER 1** e o outro na aba **PLAYER 2**.
3. Durante o jogo, o segundo jogador entra apertando **START**.

## Deu erro? Soluções rápidas

| Problema | O que fazer |
|---|---|
| `winget` não é reconhecido | Atualize o **Instalador de Aplicativo** pela Microsoft Store, ou instale o [Git](https://git-scm.com/downloads/win) e o [Python](https://www.python.org/downloads/windows/) pelos sites (no Python, marque **"Add python.exe to PATH"**). |
| `git` ou `python` não é reconhecido | Feche e abra o PowerShell de novo depois de instalar. |
| `python` abre a Microsoft Store | Em **Configurações → Aplicativos → Configurações avançadas de aplicativos → Aliases de execução**, desligue `python.exe` e `python3.exe`. |
| "Disc verified" não aparece | Sua imagem não é a versão USA esperada. Confira o tamanho e o SHA1 do Passo 1. |
| O instalador parou com erro | Rode o Passo 4 de novo (é seguro repetir). Se o erro persistir, abra uma issue com a mensagem que apareceu. |

## Problemas conhecidos

- O Metal Slug X carrega partes do código do disco durante o jogo. Na primeira vez que um trecho
  novo aparece, ele roda num interpretador e é convertido em segundo plano, o que pode causar
  pequenos engasgos. Nas próximas vezes, o trecho já roda nativo.
- O modo online (netplay) do psxrecomp não está habilitado neste projeto.

Encontrou um travamento? Abra uma [issue](https://github.com/lleandroRodrigzz/MetalSlugXRecomp/issues)
dizendo a fase, o que estava acontecendo e o conteúdo do arquivo `build-release\psx_crash.txt`, se ele existir.

## Créditos e aviso legal

- Recompilação: [psxrecomp](https://github.com/mstan/psxrecomp) e
  [recomp-ui](https://github.com/RetroPortingToolKit/recomp-ui) (mstan / RetroPortingToolKit).
- *Metal Slug X* é © SNK. Este é um projeto de fãs, sem vínculo com a SNK.
- Nenhuma imagem de disco, BIOS ou código do jogo é distribuído neste repositório. Você precisa
  ter o jogo original.
