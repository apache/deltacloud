/*************************************************************************
 * 
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.  The
 * ASF licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 * 
 *************************************************************************/
package org.jboss.tools.internal.deltacloud.client.test.fakes;

import java.io.IOException;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ServerFake {

	public static final int DEFAULT_PORT = 3003;
	private ExecutorService executor;
	private int port;
	private String response;
	private ServerFakeSocket serverSocket;

	public ServerFake(String response) {
		this(DEFAULT_PORT, response);
	}

	public ServerFake(int port, String response) {
		this.port = port;
		this.response = response;
	}

	public void start() {
		executor = Executors.newFixedThreadPool(1);
		this.serverSocket = new ServerFakeSocket(port, response);
		executor.submit(serverSocket);
	}

	public void stop() {
		executor.shutdownNow();
		serverSocket.shutdown();
	}

	private class ServerFakeSocket implements Runnable {
		private String response;
		private ServerSocket serverSocket;

		private ServerFakeSocket(int port, String response) {

			this.response = response;

			try {
				this.serverSocket = new ServerSocket(port);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		public void shutdown() {
			try {
				this.serverSocket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		@Override
		public void run() {
			Socket socket;
			try {
				socket = serverSocket.accept();
				OutputStream outputStream = socket.getOutputStream();
				outputStream.write(response.getBytes());
				outputStream.flush();
				outputStream.close();
				socket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
}