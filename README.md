# Deploying Wickr on Snowball Edge

Wickr has developed the industry’s most secure, end-to-end encrypted, communication technology. With Wickr, customers and partners benefit from advanced security features not available with traditional communications services – across messaging, voice and video calling, file sharing, and collaboration. This gives security conscious enterprises and government agencies the ability to implement important governance and security controls to help them meet their compliance requirements.
This repo will deploy the Wickr Messaging, Voice and Video, and Compliance servers on a Snowball Edge.

## Conceptual Federated Architecture
![Architectural Overview](SBEWickrFederationConcept.drawio.png)
(drawing by Troy Barker)

### Instructions
1. Download all files from this repo
2. Edit `launch_ec2.sh` to reflect your environment
3. `chmod +x launch_ec2.sh`
4. `./launch_ec2.sh`

Once the servers have been deployed, the user will have to go to the browser to finish the setup (http://<messaging_server_ip_address>:8800)
